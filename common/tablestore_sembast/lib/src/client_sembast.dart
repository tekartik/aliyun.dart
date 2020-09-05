import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:tekartik_aliyun_tablestore/src/ts_row.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/tablestore_sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

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
        throw TsException('table $name not found');
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
        throw TsException('table $name already exists');
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
        throw TsException('table $tableName does not exists');
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
  Future<TsGetRowResponse> getRow(TsGetRowRequest request) {
    // TODO: implement getRow
    throw UnimplementedError();
  }

  @override
  Future<TsPutRowResponse> putRow(TsPutRowRequest request) {
    // TODO: implement putRow
    throw UnimplementedError();
  }
}
