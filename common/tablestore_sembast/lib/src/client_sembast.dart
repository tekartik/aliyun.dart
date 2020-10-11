import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sembast/blob.dart';
import 'package:sembast/sembast.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/client_sembast_exception.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/tablestore_sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

import 'import.dart';

var metaStore = StoreRef<String, dynamic>('meta');
var metaMapStore = metaStore.cast<String, Map<String, dynamic>>();
var metaVersionKey = 'version';
var versionRecord = metaMapStore.record(metaVersionKey);
var tablesMetaRecord = metaStore.record('tables').cast<String, List<dynamic>>();

RecordRef<String, Map<String, dynamic>> getTableMetaRecord(String tableName) =>
    metaMapStore.record('table_meta_$tableName');

RecordRef<String, Map<String, dynamic>> getTableExtraInfoRecord(
        String tableName) =>
    metaMapStore.record('table_extra_$tableName');

StoreRef<int, Map<String, dynamic>> getTableStore(String tableName) =>
    intMapStoreFactory.store('table_$tableName');

Future<TsTableDescriptionTableMeta> getTableMeta(
    DatabaseClient client, String tableName) async {
  var tableMetaRecord = getTableMetaRecord(tableName);
  var tableMetaRaw = await tableMetaRecord.get(client);
  if (tableMetaRaw == null) {
    throw TsExceptionSembast(message: 'table $tableName does not exists');
  }
  return TsTableDescriptionTableMeta.fromMap(tableMetaRaw);
}

/// Table context to get first.
Future<TsTableContextSembast> getTableContext(
    DatabaseClient client, String tableName) async {
  var tableMetaRecord = getTableMetaRecord(tableName);
  var tableMetaRaw = await tableMetaRecord.get(client);
  if (tableMetaRaw == null) {
    throw TsExceptionSembast(
        message: 'table $tableName does not exists',
        isTableNotExistError: true);
  }
  return TsTableContextSembast(
      client, TsTableDescriptionTableMeta.fromMap(tableMetaRaw));
}

class TsClientSembast implements TsClient {
  final TablestoreSembast tablestore;
  final TsClientOptions options;

  Future<Database> __db;

  TsClientSembast(this.tablestore, this.options);

  Future<Database> get _db => __db ??= () {
        var relativeTopPath =
            join('.dart_tool', 'tekartik_aliyun', 'tablestore');
        String path;
        var instanceName = options?.instanceName ?? 'default.db';
        if (isRelative(instanceName)) {
          path = join(relativeTopPath, instanceName);
        } else {
          path = instanceName;
        }
        if (debugTs) {
          print('[SBi] Opening $path');
        }
        return tablestore.factory.openDatabase(path, version: 1,
            onVersionChanged: (db, oldVersion, newVersion) async {
          if (oldVersion == 0) {
            // create
            await versionRecord.put(db, {'tekartik_tablestore': 1});
          } else {}
        });
      }();

  Future<List<String>> _listTableNames(DatabaseClient client) async {
    return (await tablesMetaRecord.get(client))?.cast<String>() ?? <String>[];
  }

  @override
  Future<List<String>> listTableNames() async {
    return _listTableNames(await _db);
  }

  // throw if not found
  @override
  Future deleteTable(String name) async {
    await (await _db).transaction((txn) async {
      var tableNames = await _listTableNames(txn);

      if (tableNames.contains(name)) {
        tableNames.remove(name);
        await tablesMetaRecord.put(txn, tableNames);
      } else {
        throw TsExceptionSembast(message: 'table $name not found');
      }
    });
  }

  @override
  Future createTable(String name, TsTableDescription description) async {
    if (name != description?.tableMeta?.tableName) {
      throw ArgumentError.value(name, description?.tableMeta?.tableName,
          'table name different in meta');
    }
    await (await _db).transaction((txn) async {
      var tableNames = List.from(await _listTableNames(txn));

      if (!tableNames.contains(name)) {
        var tableMetaRecord = getTableMetaRecord(name);
        var tableExtraRecord = getTableExtraInfoRecord(name);
        tableNames.add(name);
        await put(txn, tablesMetaRecord, tableNames);
        await put(txn, tableMetaRecord, description.tableMeta.toMap());
        await put(
            txn,
            tableExtraRecord,
            // Remove table meta
            TsTableDescription(
                    reservedThroughput: description.reservedThroughput,
                    tableOptions: description.tableOptions)
                .toMap());
      } else {
        throw TsExceptionSembast(message: 'table $name already exists');
      }
    });
  }

  Future<V /*?*/ > put<K, V>(
      DatabaseClient client, RecordRef<K, V> record, V value) {
    if (debugTs) {
      print('[SBw] $record $value');
    }
    return record.put(client, value);
  }

  @override
  Future<TsTableDescription> describeTable(String tableName) async {
    return await (await _db).transaction((txn) async {
      var tableMetaRecord = getTableMetaRecord(tableName);
      var tableExtraRecord = getTableExtraInfoRecord(tableName);
      var tableMetaRaw = await tableMetaRecord.get(txn);
      TsTableDescription extra;
      if (tableMetaRaw == null) {
        throw TsExceptionSembast(message: 'table $tableName does not exists');
      }
      var tableExtraRaw = await tableExtraRecord.get(txn);
      if (tableExtraRaw != null) {
        // Everything but tableMeta
        extra = TsTableDescription.fromMap(tableExtraRaw);
      }

      return TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta.fromMap(tableMetaRaw),
          reservedThroughput: extra.reservedThroughput,
          tableOptions: extra.tableOptions);
    });
  }

  @override
  Future<TsGetRowResponse> getRow(TsGetRowRequest request) async {
    return await (await _db).transaction((txn) async {
      var table = await getTableContext(txn, request.tableName);
      var row = table.row(request.primaryKey);
      var record = row.record();
      var result = await record.get(request.columns);
      var exists = result != null;
      return TsGetRowResponseSembast(
          row, exists, result?.primaryKey, result?.attributes);
    });
  }

  @override
  Future<TsPutRowResponse> putRow(TsPutRowRequest request) async {
    return await (await _db).transaction((txn) async {
      var table = await getTableContext(txn, request.tableName);
      var row = table.row(request.primaryKey);
      var record = row.record(request.data);
      var key = await _checkPutDeleteCondition(record, request.condition);
      if (key != null) {
        await record.delete();
      }
      await record.put();
      return TsPutRowResponseSembast(row);
    });
  }

  Future<int> _checkPutDeleteCondition(
      TsRowRecordContextSembast record, TsCondition condition) async {
    var key = await record.findKey();

    switch (condition?.rowExistenceExpectation) {
      case TsConditionRowExistenceExpectation.ignore:
        break;
      case TsConditionRowExistenceExpectation.expectExist:
        if (key == null) {
          throw TsExceptionSembast(
              message: 'record not found', isConditionFailedError: true);
        }
        break;
      case TsConditionRowExistenceExpectation.expectNotExist:
        if (key != null) {
          throw TsExceptionSembast(
              message: 'record found', isConditionFailedError: true);
        }
    }
    return key;
  }

  @override
  Future<TsDeleteRowResponse> deleteRow(TsDeleteRowRequest request) async {
    return await (await _db).transaction((txn) async {
      var table = await getTableContext(txn, request.tableName);
      var row = table.row(request.primaryKey);
      var record = row.record();
      var key = await _checkPutDeleteCondition(record, request.condition);
      if (key != null) {
        await record.deleteByKey(key);
      }
      return TsDeleteRowResponseSembast();
    });
  }

  @override
  Future<TsGetRangeResponse> getRange(TsGetRangeRequest request) async {
    return await (await _db).transaction((txn) async {
      //var range = await getTableContext(client, tableName)
      var table = await getTableContext(txn, request.tableName);
      var range = table.range(request);
      var result = await range.get();

      return TsGetRangeResponseSembast(result.rows, result.nextRow?.primaryKey);
    });
  }

  @override
  Future<TsBatchGetRowsResponse> batchGetRows(
      TsBatchGetRowsRequest request) async {
    return await (await _db).transaction((txn) async {
      var tables = <List<TsBatchGetRowResponseRowSembast>>[];
      for (var requestTable in request.tables) {
        var rows = <TsBatchGetRowResponseRowSembast>[];
        var table = await getTableContext(txn, requestTable.tableName);
        for (var primaryKey in requestTable.primaryKeys) {
          var row = table.row(primaryKey);

          var record = row.record();
          var result = await record.get(requestTable.columns);
          // return TsGetRowResponseSembast(row, result.primaryKey, result.attributes);
          var isOk = true;

          rows.add(TsBatchGetRowResponseRowSembast(
              rowContext: row, attributes: result?.attributes, isOk: isOk));
        }
        tables.add(rows);
      }
      return TsBatchGetRowsResponseSembast(tables);
    });
  }

  @override
  Future<TsBatchWriteRowsResponse> batchWriteRows(
      TsBatchWriteRowsRequest request) async {
    return await (await _db).transaction((txn) async {
      var rows = <TsBatchGetRowResponseRowSembast>[];
      for (var requestTable in request.tables) {
        var table = await getTableContext(txn, requestTable.tableName);
        for (var requestRow in requestTable.rows) {
          var row = table.row(requestRow.primaryKey);
          var record = row.record(requestRow.data);
          var isOk = true;
          String errorMessage;
          // int errorCode;
          try {
            var key =
                await _checkPutDeleteCondition(record, requestRow.condition);
            if (key != null) {
              await record.delete();
            }
          } on TsExceptionSembast catch (e) {
            isOk = false;
            errorMessage = e.message;
            // errorCode = e.

          }
          await record.put();
          rows.add(TsBatchGetRowResponseRowSembast(
              rowContext: row,
              attributes: TsAttributes([]),
              isOk: isOk,
              errorMessage: errorMessage));
        }
      }
      return TsBatchWriteRowsResponseSembast(rows);
    });
  }

  @override
  Future<TsUpdateRowResponse> updateRow(TsUpdateRowRequest request) async {
    return await (await _db).transaction((txn) async {
      var table = await getTableContext(txn, request.tableName);
      var row = table.row(request.primaryKey);
      var record = row.record();
      var key = await _checkPutDeleteCondition(
          record,
          request.condition ??
              TsCondition(
                  rowExistenceExpectation:
                      TsConditionRowExistenceExpectation.expectExist));

      var list = <TsAttribute>[];
      if (key != null) {
        list.addAll((await record.get(null))?.attributes);
      }
      // Merge!
      for (var update in request.data) {
        if (update is TsUpdateAttributePut) {
          for (var attribute in update.attributes) {
            list.removeWhere((element) => element.name == attribute.name);
            list.add(attribute);
          }
        } else if (update is TsUpdateAttributeDelete) {
          list.removeWhere((element) => update.fields.contains(element.name));
        }
      }
      record = row.record(list);
      await record.delete();
      await record.put();
      return TsUpdateRowResponseSembast(row);
    });
  }

  @override
  Future<TsStartLocalTransactionResponse> startLocalTransaction(
      TsStartLocalTransactionRequest request) {
    // TODO: implement startLocalTransaction
    throw UnimplementedError();
  }
}

class TsGetRangeResponseSembast implements TsGetRangeResponse {
  @override
  final List<TsGetRowSembast> rows;

  TsGetRangeResponseSembast(this.rows, this.nextStartPrimaryKey);

  @override
  final TsPrimaryKey nextStartPrimaryKey;
}

class TsBatchGetRowsResponseSembast implements TsBatchGetRowsResponse {
  @override
  final List<List<TsBatchGetRowsResponseRow>> tables;

  TsBatchGetRowsResponseSembast(this.tables);
}

class TsBatchWriteRowsResponseSembast implements TsBatchWriteRowsResponse {
  TsBatchWriteRowsResponseSembast(this.rows);

  @override
  final List<TsBatchGetRowsResponseRow> rows;
}

class TsBatchGetRowResponseRowSembast implements TsBatchGetRowsResponseRow {
  final TsRowContextSembast rowContext;

  TsBatchGetRowResponseRowSembast(
      {this.attributes,
      this.errorCode,
      this.errorMessage,
      this.isOk,
      this.rowContext});

  @override
  final TsAttributes attributes;

  @override
  final int errorCode;

  @override
  final String errorMessage;

  @override
  final bool isOk;

  @override
  TsPrimaryKey get primaryKey => rowContext.primaryKey;

  @override
  String get tableName => rowContext.tableName;
}

class TsGetRowSembast implements TsGetRow {
  @override
  final bool exists;

  TsGetRowSembast(this.exists, this.primaryKey, this.attributes);

  @override
  final TsPrimaryKey primaryKey;
  @override
  final TsAttributes attributes;
}

dynamic valueToSembastValue(dynamic value) {
  assert(value == null ||
      value is TsValueLong ||
      value is String ||
      value is Uint8List ||
      value is double);
  if (value is TsValueLong) {
    return value.toNumber();
  } else if (value is Uint8List) {
    return Blob(value);
  }
  return value;
}

dynamic sembastValueToValue(dynamic value) {
  if (value is Blob) {
    return value.bytes;
  }
  if (value is int) {
    return TsValueLong.fromNumber(value);
  }
  return value;
}

class TsTableContextSembast {
  final DatabaseClient client;
  final TsTableDescriptionTableMeta tableMeta;

  TsTableContextSembast(this.client, this.tableMeta);

  StoreRef<int, Map<String, dynamic>> get store => getTableStore(tableName);

  String get tableName => tableMeta.tableName;

  List<String> get primaryKeyNames =>
      tableMeta.primaryKeys.map((e) => e.name).toList(growable: false);

  void checkPrimaryKey(TsPrimaryKey primaryKey) {
    // Check size
    if (primaryKey.list.length != tableMeta.primaryKeys.length) {
      throw TsExceptionSembast(
          message: 'PK size fail', isPrimaryKeySizeError: true);
    }
    for (var i = 0; i < primaryKey.list.length; i++) {
      var def = tableMeta.primaryKeys[i];
      var key = primaryKey.list[i];
      switch (def.type) {
        case TsColumnType.integer:
          if (!(key.value is TsValueLong || key.value is TsValueInfinite)) {
            throw TsExceptionSembast(
                message: 'PK type fail, expecting int for $key',
                isPrimaryKeyTypeError: true);
          }
          break;
        case TsColumnType.string:
          if (!(key.value is String || key.value is TsValueInfinite)) {
            throw TsExceptionSembast(
                message: 'PK type fail, expecting String for $key',
                isPrimaryKeyTypeError: true);
          }
          break;
        case TsColumnType.binary:
          if (!(key.value is Uint8List || key.value is TsValueInfinite)) {
            throw TsExceptionSembast(
                message: 'PK type fail, expecting Uint8List for $key',
                isPrimaryKeyTypeError: true);
          }
          break;
      }
    }
  }

  TsRowContextSembast row(TsPrimaryKey primaryKey) {
    checkPrimaryKey(primaryKey);
    return TsRowContextSembast(this, primaryKey);
  }

  TsRangeContextSembast range(TsGetRangeRequest request) {
    if (request.inclusiveStartPrimaryKey != null) {
      checkPrimaryKey(request.inclusiveStartPrimaryKey);
    }
    if (request.exclusiveEndPrimaryKey != null) {
      checkPrimaryKey(request.exclusiveEndPrimaryKey);
    }
    return TsRangeContextSembast(this, request);
  }
}

class KeyValueSembast {
  String key;
  dynamic value;

  KeyValueSembast.from(TsKeyValue tsKeyValue) {
    key = tsKeyValue.name;
    value = valueToSembastValue(tsKeyValue.value);
  }
}

List<KeyValueSembast> toSembastKeyValues(List<TsKeyValue> tsKeyValues) =>
    tsKeyValues.map((e) => KeyValueSembast.from(e)).toList(growable: false);

List<TsKeyValue> readKeyValues(Map map, List<String> names) {
  var list = <TsKeyValue>[];
  for (var name in names) {
    var value = sembastValueToValue(map[name]);
    list.add(TsKeyValue(name, value));
  }
  return list;
}

/// Read all columns
List<TsAttribute> readAttributesBut(Map map, List<String> but) {
  var list = <TsAttribute>[];
  map.forEach((key, value) {
    if (!but.contains(key)) {
      var value = sembastValueToValue(map[key]);
      list.add(TsAttribute(key as String, value));
    }
  });
  return list;
}

/// Read all columns if columns is null or empty (!), none if empty, exclude [but]
List<TsAttribute> readAttributesColumnsBut(
    Map map, List<String> columns, List<String> but) {
  if (columns == null || columns.isEmpty) {
    return readAttributesBut(map, but);
  }
  var list = <TsAttribute>[];

  columns.forEach((key) {
    if (!but.contains(key)) {
      if (map.containsKey(key)) {
        var value = sembastValueToValue(map[key]);
        list.add(TsAttribute(key, value));
      }
    }
  });
  return list;
}

class TsRowRecordContextSembast {
  final TsRowContextSembast row;

  TsTableContextSembast get table => row.table;

  DatabaseClient get client => table.client;
  final List<TsAttribute> attributes;

  final _data = Model();
  final _keys = <String>[];
  List<KeyValueSembast> _sembastPrimaryKeys;
  List<KeyValueSembast> _sembastAttributes;

  List<KeyValueSembast> get sembastPrimaryKeys => _sembastPrimaryKeys ??= () {
        return toSembastKeyValues(row.primaryKey.list);
      }();

  List<KeyValueSembast> get sembastAttributes => _sembastAttributes ??= () {
        if (attributes == null) {
          return null;
        }
        return toSembastKeyValues(attributes);
      }();

  Finder _finder;

  Finder get finder => _finder ??= () {
        return Finder(
            filter: Filter.and(sembastPrimaryKeys
                .map((e) => Filter.equals(e.key, e.value))
                .toList()));
      }();

  Future delete() async {
    // delete previous
    await table.store.delete(table.client, finder: finder);
  }

  Future deleteByKey(int key) async {
    // delete previous
    await table.store.record(key).delete(table.client);
  }

  Future<int> findKey() async {
    // delete previous
    var ids = await table.store.findKeys(client, finder: finder);
    // Delete others..in case any
    if (ids.length > 1) {
      // should not happen
      print(
          'deleting ${ids.length - 1} existing records with key $sembastPrimaryKeys');
      await table.store.records(ids.sublist(1)).delete(client);
    }
    if (ids.isNotEmpty) {
      return ids[0];
    }
    return null;
  }

  void _add(List<KeyValueSembast> keyValues) {
    for (var item in keyValues) {
      _keys.add(item.key);
      _data[item.key] = item.value;
    }
  }

  // Return the primary key
  Future<TsPrimaryKey> put() async {
    _data.clear();
    _keys.clear();
    _add(sembastPrimaryKeys);
    if (sembastAttributes != null) {
      _add(sembastAttributes);
    }

    // ignore: unused_local_variable
    var result = await table.store.add(table.client, _data);
    return row.primaryKey;
  }

  TsRowRecordContextSembast(this.row, [this.attributes]);

  TsGetRowSembast recordValueToGetRowSembast(Map map, List<String> columns) {
    var primaryKey = TsPrimaryKey(readKeyValues(map, table.primaryKeyNames));
    var attributes =
        sembastRecordValueToAttributes(map, columns, table.primaryKeyNames);
    var exists = map != null;
    return TsGetRowSembast(exists, primaryKey, attributes);
  }

  /// Filter columns, all if null
  Future<TsGetRowSembast> get(List<String> /*?*/ columns) async {
    var id = await findKey();
    if (id != null) {
      var result = await table.store.record(id).get(table.client);
      return recordValueToGetRowSembast(result, columns);
    }
    return null;
  }
}

class TsRowContextSembast {
  final TsTableContextSembast table;
  final TsPrimaryKey primaryKey;

  TsRowContextSembast(this.table, this.primaryKey);

  String get tableName => table.tableName;

  /// Null record for get
  TsRowRecordContextSembast record([List<TsAttribute> attributes]) {
    if (attributes != null) {
      for (var attribute in attributes) {
        if (!(attribute.value is String ||
            attribute.value is TsValueLong ||
            attribute.value is Uint8List)) {
          throw TsExceptionSembast(
              message:
                  'Invalid value type for $attribute ${attribute.value?.runtimeType}',
              retryable: false);
        }
      }
    }
    return TsRowRecordContextSembast(this, attributes);
  }
}

class TsGetRowResponseSembast extends TsReadRowResponseSembast
    implements TsGetRowResponse {
  final TsAttributes attributes;
  final TsPrimaryKey primaryKey;

  TsGetRowResponseSembast(TsRowContextSembast rowContext, bool exists,
      this.primaryKey, this.attributes)
      : super(rowContext, exists);

  @override
  TsGetRow get row => TsGetRowSembast(exists, primaryKey, attributes);
}

class TsReadRowResponseSembast {
  final bool exists;
  final TsRowContextSembast rowContext;

  TsReadRowResponseSembast(this.rowContext, this.exists);

  TsGetRow get row =>
      TsGetRowSembast(exists, rowContext.primaryKey, TsAttributes([]));
}

class TsPutRowResponseSembast extends TsReadRowResponseSembast
    implements TsPutRowResponse {
  TsPutRowResponseSembast(TsRowContextSembast rowContext)
      : super(rowContext, true);
}

class TsDeleteRowResponseSembast implements TsDeleteRowResponse {}

class TsUpdateRowResponseSembast extends TsReadRowResponseSembast
    implements TsUpdateRowResponse {
  TsUpdateRowResponseSembast(TsRowContextSembast rowContext)
      : super(rowContext, true);
}

Filter tsConditionToSembastFilter(TsColumnCondition condition) {
  if (condition == null) {
    return null;
  }
  if (condition is TsColumnCompositeCondition) {
    switch (condition.operator) {
      case TsLogicalOperator.and:
        assert(condition.list.length > 1);
        return Filter.and(
            condition.list.map(tsConditionToSembastFilter).toList());
      case TsLogicalOperator.or:
        assert(condition.list.length > 1);
        return Filter.or(
            condition.list.map(tsConditionToSembastFilter).toList());
      case TsLogicalOperator.not:
        assert(condition.list.length == 1);
        throw UnsupportedError('\'not\' not supported yet');
    }
  } else if (condition is TsColumnSingleCondition) {
    switch (condition.operator) {
      case TsComparatorType.equals:
        return Filter.equals(
            condition.name, valueToSembastValue(condition.value));
      case TsComparatorType.notEquals:
        return Filter.notEquals(
            condition.name, valueToSembastValue(condition.value));
      case TsComparatorType.greaterThan:
        return Filter.greaterThan(
            condition.name, valueToSembastValue(condition.value));
      case TsComparatorType.greaterThanOrEquals:
        return Filter.greaterThanOrEquals(
            condition.name, valueToSembastValue(condition.value));
      case TsComparatorType.lessThan:
        return Filter.lessThan(
            condition.name, valueToSembastValue(condition.value));
      case TsComparatorType.lessThanOrEquals:
        return Filter.lessThanOrEquals(
            condition.name, valueToSembastValue(condition.value));
    }
  }
  throw 'Unsupported condition $condition';
}

class TsGetRangeSembast {
  final List<TsGetRowSembast> rows;
  final TsGetRowSembast nextRow;

  TsGetRangeSembast(this.rows, this.nextRow);
}

class TsRangeContextSembast {
  final TsTableContextSembast table;
  final TsGetRangeRequest request;

  TsRangeContextSembast(this.table, this.request);

  Filter _and(Filter filter1, Filter filter2) {
    if (filter1 == null) {
      return filter2;
    } else if (filter2 == null) {
      return filter1;
    }
    return Filter.and([filter1, filter2]);
  }

  Future<TsGetRangeSembast> get() async {
    Filter boundaryFilter;
    var columnFilter = tsConditionToSembastFilter(request.columnCondition);
    var startPrimaryKey = request.inclusiveStartPrimaryKey;
    var endPrimaryKey = request.exclusiveEndPrimaryKey;

    if (startPrimaryKey != null || endPrimaryKey != null) {
      boundaryFilter = Filter.custom((record) {
        if (startPrimaryKey != null) {
          for (var kv in startPrimaryKey.list) {
            var field = kv.name;
            if (kv.value == TsValueInfinite.min) {
              break;
            } else if (kv.value == TsValueInfinite.max) {
              return false;
            } else {
              var value = record[field] as Comparable;
              var cmp = value.compareTo(valueToSembastValue(kv.value));
              if (cmp < 0) {
                return false;
              } else if (cmp > 0) {
                break;
              }
              // equals continue!
            }
          }
        }

        if (endPrimaryKey != null) {
          for (var i = 0; i < endPrimaryKey.list.length; i++) {
            var kv = endPrimaryKey.list[i];
            var field = kv.name;
            if (kv.value == TsValueInfinite.min) {
              return false;
            } else if (kv.value == TsValueInfinite.max) {
              break;
            } else {
              var value = record[field] as Comparable;
              var cmp = value.compareTo(valueToSembastValue(kv.value));
              if (cmp > 0) {
                return false;
              } else if (cmp < 0) {
                break;
              }
              // Last field make it strict
              if (i == endPrimaryKey.list.length - 1) {
                return false;
              }
            }
          }
        }
        // Condition
        return true;
      });
    }
    var finder = Finder(
        filter: _and(boundaryFilter, columnFilter),
        sortOrders:
            table.tableMeta.primaryKeys.map((e) => SortOrder(e.name)).toList(),
        // Add 1 for next
        limit: request.limit != null ? request.limit + 1 : null);

    var records = await table.store.find(table.client, finder: finder);

    TsGetRowSembast nextRow;

    var rows = records.map((snapshot) {
      var result = snapshot.value;

      var primaryKey =
          TsPrimaryKey(readKeyValues(result, table.primaryKeyNames));

      var attributes = sembastRecordValueToAttributes(
          result, request.columns, table.primaryKeyNames);

      return TsGetRowSembast(true, primaryKey, attributes);
    }).toList();

    if (request.limit != null && rows.length > request.limit) {
      // Pick last
      nextRow = rows[request.limit];
      // Remove last
      rows = rows.sublist(0, request.limit);
    }

    return TsGetRangeSembast(rows, nextRow);
  }
}

TsAttributes sembastRecordValueToAttributes(
    Map map, List<String> columns, List<String> but) {
  var attributes = TsAttributes(readAttributesColumnsBut(map, columns, but));
  return attributes;
}
