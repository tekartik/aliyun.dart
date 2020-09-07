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
    throw TsExceptionSembast(message: 'table $tableName does not exists');
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
          print('[SBi] Openeing $path');
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
      var result = await record.get();
      return TsGetRowResponseSembast(row, result.primaryKey, result.attributes);
      /*
      var tableExtraRaw = await tableExtraRecord.get(txn);
      if (tableExtraRaw != null) {
        // Everything but tableMeta
        extra = TsTableDescription.fromMap(tableExtraRaw);
      }

      return TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta.fromMap(tableMetaRaw),
          reservedThroughput: extra.reservedThroughput,
          tableOptions: extra.tableOptions);
          */
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
      //var table = await getTableContext(txn, request.tableName);
      /*
      var row = table.row(request.primaryKey);
      var record = row.record();
      var key = await _checkPutDeleteCondition(record, request.condition);
      if (key != null) {
        await record.deleteByKey(key);
      }

       */
      // return TsDeleteRowResponseSembast();
      return null;
    });
  }
}

class TsGetRowSembast implements TsGetRow {
  TsGetRowSembast(this.primaryKey, this.attributes);

  @override
  final TsPrimaryKey primaryKey;
  @override
  final List<TsAttribute> attributes;
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

  TsRowContextSembast row(TsPrimaryKey primaryKey) {
    return TsRowContextSembast(this, primaryKey);
  }

  TsRangeContextSembast range(TsGetRangeRequest request) {
    return null; // TODO
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

  List<TsKeyValue> read(Map map, List<String> names) {
    var list = <TsKeyValue>[];
    for (var name in names) {
      var value = sembastValueToValue(map[name]);
      list.add(TsKeyValue(name, value));
    }
    return list;
  }

  List<TsAttribute> readAttributesBut(Map map, List<String> names) {
    var list = <TsAttribute>[];
    map.forEach((key, value) {
      if (!names.contains(key)) {
        var value = sembastValueToValue(map[key]);
        list.add(TsAttribute(key as String, value));
      }
    });
    return list;
  }

  Future<TsGetRowSembast> get() async {
    var id = await findKey();
    if (id != null) {
      var result = await table.store.record(id).get(table.client);
      var primaryKey = TsPrimaryKey(read(result, table.primaryKeyNames));
      var attributes = readAttributesBut(result, table.primaryKeyNames);
      return TsGetRowSembast(primaryKey, attributes);
    }
    return null;
  }
}

class TsRowContextSembast {
  final TsTableContextSembast table;
  final TsPrimaryKey primaryKey;

  TsRowContextSembast(this.table, this.primaryKey);

  /// Null record for get
  TsRowRecordContextSembast record([List<TsAttribute> attributes]) =>
      TsRowRecordContextSembast(this, attributes);
}

class TsGetRowResponseSembast extends TsReadRowResponseSembast
    implements TsGetRowResponse {
  final List<TsAttribute> attributes;
  final TsPrimaryKey primaryKey;

  TsGetRowResponseSembast(
      TsRowContextSembast rowContext, this.primaryKey, this.attributes)
      : super(rowContext);

  @override
  TsGetRow get row => TsGetRowSembast(primaryKey, attributes);
}

class TsReadRowResponseSembast {
  final TsRowContextSembast rowContext;

  TsReadRowResponseSembast(this.rowContext);

  TsGetRow get row => TsGetRowSembast(rowContext.primaryKey, []);
}

class TsPutRowResponseSembast extends TsReadRowResponseSembast
    implements TsPutRowResponse {
  TsPutRowResponseSembast(TsRowContextSembast rowContext) : super(rowContext);
}

class TsDeleteRowResponseSembast implements TsDeleteRowResponse {}

class TsRangeContextSembast {
  final TsTableContextSembast table;
  final TsGetRangeRequest request;

  TsRangeContextSembast(this.table, this.request);
}
