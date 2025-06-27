import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:test/test.dart';

var twoKeysTable = 'test_create';
bool _table1Created = false;

Future createTable1(TsClient client) async {
  if (!_table1Created) {
    var names = await client.listTableNames();
    if (!names.contains(twoKeysTable)) {
      await client.createTable(
        twoKeysTable,
        TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta(
            tableName: twoKeysTable,
            primaryKeys: [
              TsPrimaryKeyDef(name: 'gid', type: TsColumnType.integer),
              TsPrimaryKeyDef(name: 'uid', type: TsColumnType.integer),
            ],
          ),
        ),
      );
    }
    names = await client.listTableNames();
    expect(names, contains(twoKeysTable));
    _table1Created = true;
  }
}

var keyStringTableName = 'test_key_string';

var _keyStringTableCreated = false;

Future createKeyStringTable(TsClient client, {String? name}) async {
  if (name != null || !_keyStringTableCreated) {
    // We are limited in the number of create, test it well and sometimes delete!
    var tableName = name ?? keyStringTableName;
    var names = await client.listTableNames();
    if (!names.contains(tableName)) {
      var description = TsTableDescription(
        tableMeta: TsTableDescriptionTableMeta(
          tableName: tableName,
          primaryKeys: [
            TsPrimaryKeyDef(name: 'key', type: TsColumnType.string),
          ],
        ),
        reservedThroughput: tableCreateReservedThroughputDefault,
        tableOptions: tableCreateOptionsDefault,
      );
      await client.createTable(tableName, description);
    }
    if (name == null) {
      _keyStringTableCreated = true;
    }
  }
}

bool _tableWorkCreated = false;
var workTableName = 'test_work';

Future createWorkTable(TsClient client) async {
  if (!_tableWorkCreated) {
    var description = TsTableDescription(
      tableMeta: TsTableDescriptionTableMeta(
        tableName: workTableName,
        primaryKeys: [
          TsPrimaryKeyDef(name: 'key1', type: TsColumnType.string),
          TsPrimaryKeyDef(name: 'key2', type: TsColumnType.integer),
          TsPrimaryKeyDef(name: 'key3', type: TsColumnType.string),
          TsPrimaryKeyDef(name: 'key4', type: TsColumnType.integer),
        ],
      ),
      reservedThroughput: tableCreateReservedThroughputDefault,
      tableOptions: tableCreateOptionsDefault,
    );
    var names = await client.listTableNames();
    if (!names.contains(workTableName)) {
      await client.createTable(workTableName, description);
    }
    _tableWorkCreated = true;
  }
}

TsPrimaryKey getWorkTableKey(
  String col1,
  Object col2,
  Object col3,
  Object col4,
) {
  return TsPrimaryKey([
    TsKeyValue('key1', col1),
    TsKeyValue('key2', col2 is int ? TsValueLong.fromNumber(col2) : col2),
    TsKeyValue('key3', col3),
    TsKeyValue('key4', col4 is int ? TsValueLong.fromNumber(col4) : col4),
  ]);
}

void tablesTest(TsClient client) {
  group('table', () {
    test('deleteTable', () async {
      var tableName = 'test_dummy_to_delete';
      try {
        await client.deleteTable(tableName);
      } catch (_) {}
      var names = await client.listTableNames();
      expect(names, isNot(contains(tableName)));
    });
    test('listTableNames', () async {
      expect(await client.listTableNames(), const TypeMatcher<List>());
    });

    var create1Table = 'test_create1';
    Future createTableCreate1() async {
      // We are limited in the number of create, test it well and sometimes delete!
      var tableName = create1Table;
      var names = await client.listTableNames();
      if (!names.contains(tableName)) {
        var description = TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta(
            tableName: create1Table,
            primaryKeys: [
              TsPrimaryKeyDef(name: 'gid', type: TsColumnType.integer),
              TsPrimaryKeyDef(name: 'uid', type: TsColumnType.integer),
            ],
          ),
          reservedThroughput: tableCreateReservedThroughputDefault,
          tableOptions: tableCreateOptionsDefault,
        );
        await client.createTable(tableName, description);
      }
    }

    test('createKeyStringTable', () async {
      // We are limited in the number of create, test it well and sometimes delete!
      await createKeyStringTable(client);
      var names = await client.listTableNames();
      expect(names, contains(keyStringTableName));
    });

    test('createTableAlways', () async {
      var tablePrefix = 'create_table_';
      var idMax = 0;
      var names = (await client.listTableNames()).where(
        (name) => name.startsWith(tablePrefix),
      );
      for (var name in names) {
        var id = parseInt(name.substring(tablePrefix.length));
        if (id != null && id > idMax) {
          idMax = id;
        }
        await client.deleteTable(name);
      }
      var name = '$tablePrefix${idMax + 1}';
      // We are limited in the number of create, test it well and sometimes delete!
      await createKeyStringTable(client, name: name);
      names = await client.listTableNames();
      expect(names, contains(name));
      expect((await client.describeTable(name)).tableMeta!.toMap(), {
        'name': name,
        'primaryKeys': [
          {'name': 'key', 'type': 'string'},
        ],
      });
    });

    test('createTable1', () async {
      // We are limited in the number of create, test it well and sometimes delete!
      await createTableCreate1();
      var names = await client.listTableNames();
      expect(names, contains(create1Table));
    });
    test('describeTable', () async {
      // We are limited in the number of create, test it well and sometimes delete!
      await createTableCreate1();

      var tableDescription = await client.describeTable(create1Table);
      var keys = ['tableMeta', 'tableOptions', 'reservedThroughput'];
      var map = tableDescription.toMap()
        ..removeWhere((key, value) => !keys.contains(key));
      expect(map, {
        'tableMeta': {
          'name': 'test_create1',
          'primaryKeys': [
            {'name': 'gid', 'type': 'integer'},
            {'name': 'uid', 'type': 'integer'},
          ],
        },
        'reservedThroughput': {
          'capacityUnit': {'read': 0, 'write': 0},
        },
        'tableOptions': {'timeToLive': -1, 'maxVersions': 1},
      });
    });

    test('createWorkTable', () async {
      await createWorkTable(client);
      var tableDescription = await client.describeTable(workTableName);
      var tableMeta = tableDescription.tableMeta!;
      expect(tableMeta.toMap(), {
        'name': workTableName,
        'primaryKeys': [
          {'name': 'key1', 'type': 'string'},
          {'name': 'key2', 'type': 'integer'},
          {'name': 'key3', 'type': 'string'},
          {'name': 'key4', 'type': 'integer'},
        ],
      });
    });
  });
}
