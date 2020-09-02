import 'package:sembast/sembast.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/tablestore_sembast.dart';
import 'package:path/path.dart';

var metaStore = StoreRef<String, dynamic>('meta');
var metaVersionKey = 'version';
var versionRecord =
    metaStore.record(metaVersionKey).cast<String, Map<String, dynamic>>();
var tablesMetaRecord = metaStore.record('tables').cast<String, List<dynamic>>();

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
        tableNames.add(name);
        await tablesMetaRecord.put(txn, tableNames);
      } else {
        throw TsException('table $name already exists');
      }
    });
  }
}
