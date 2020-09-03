import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/tablestore_sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

var metaStore = StoreRef<String, dynamic>('meta');
var metaMapStore = metaStore.cast<String, Map<String, dynamic>>();
var metaVersionKey = 'version';
var versionRecord = metaMapStore.record(metaVersionKey);
var tablesMetaRecord = metaStore.record('tables').cast<String, List<dynamic>>();

RecordRef<String, Map<String, dynamic>> getTableMetaRecord(String tableName) =>
    metaMapStore.record('table_$tableName');

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
  Future createTable(String name) async {
    await (await _db).transaction((txn) async {
      var tableNames = await _listTableNames(txn);

      if (!tableNames.contains(name)) {
        var tableMetaRecord = getTableMetaRecord(name);
        tableNames.add(name);
        await tablesMetaRecord.put(txn, tableNames);
        await tableMetaRecord.put(txn, <String, dynamic>{'primaryKeys': []});
      } else {
        throw TsException('table $name already exists');
      }
    });
  }

  @override
  Future<TsTableDescription> describeTable(String tableName) async {
    return await (await _db).transaction((txn) async {
      var tableMetaRecord = getTableMetaRecord(tableName);
      var tableMetaRaw = await tableMetaRecord.get(txn);
      if (tableMetaRaw == null) {
        throw TsException('table $tableName does not exists');
      }

      // devPrint('table: ${tableMetaRaw}');
      var primaryKeysRaw = tableMetaRaw['primaryKeys'] as List;
      //List<TsPrimaryKey> primaryKeys;
      //if (primaryKeysRaw ! )
      return TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta(
              tableName: tableName,
              primaryKeys: nativePrimaryKeysRawToPrimaryKey(primaryKeysRaw)));
    });
  }
}

int columnTypeToSembast(TsColumnType type) {
  switch (type) {
    case TsColumnType.integer:
      return 1;
    case TsColumnType.string:
      return 1;
  }
  throw UnsupportedError('sembast type $type)');
}

TsColumnType sembastColumnTypeToColumnType(int type) {
  switch (type) {
    case 1:
      return TsColumnType.integer;
    case 2:
      return TsColumnType.string;
  }
  throw UnsupportedError('native type $type');
}

List<TsPrimaryKey> nativePrimaryKeysRawToPrimaryKey(List native) {
  if (native != null) {
    var keys = <TsPrimaryKey>[];
    native.forEach((element) {
      var primaryKeyRaw = element as Map;
      keys.add(TsPrimaryKey(
          name: primaryKeyRaw['name'],
          type: sembastColumnTypeToColumnType(primaryKeyRaw['name'])));
    });
  }
  return null;
}
