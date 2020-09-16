import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:test/test.dart';

var table1Name = 'test_create1';
bool _table1Created = false;
Future createTable1(TsClient client) async {
  if (!_table1Created) {
    var names = await client.listTableNames();
    if (!names.contains(table1Name)) {
      await client.createTable(
          table1Name,
          TsTableDescription(
              tableMeta: TsTableDescriptionTableMeta(
                  tableName: table1Name,
                  primaryKeys: [
                TsPrimaryKeyDef(name: 'gid', type: TsColumnType.integer),
                TsPrimaryKeyDef(name: 'uid', type: TsColumnType.integer)
              ])));
    }
    names = await client.listTableNames();
    expect(names, contains(table1Name));
    _table1Created = true;
  }
}

bool _tableWorkCreated = false;
var workTable = 'test_work2';
Future createWorkTable(TsClient client) async {
  if (!_tableWorkCreated) {
    var description = TsTableDescription(
        tableMeta:
            TsTableDescriptionTableMeta(tableName: workTable, primaryKeys: [
          TsPrimaryKeyDef(name: 'key1', type: TsColumnType.string),
          TsPrimaryKeyDef(name: 'key2', type: TsColumnType.integer),
          TsPrimaryKeyDef(name: 'key3', type: TsColumnType.string),
          TsPrimaryKeyDef(name: 'key4', type: TsColumnType.integer),
        ]),
        reservedThroughput: tableCreateReservedThroughputDefault,
        tableOptions: tableCreateOptionsDefault);
    var names = await client.listTableNames();
    if (!names.contains(workTable)) {
      await client.createTable(workTable, description);
    }
    _tableWorkCreated = true;
  }
}

TsPrimaryKey getWorkTableKey(String col1, int col2, String col3, int col4) {
  return TsPrimaryKey([
    TsKeyValue('key1', col1),
    TsKeyValue('key2', TsValueLong.fromNumber(col2)),
    TsKeyValue('key3', col3),
    TsKeyValue('key4', TsValueLong.fromNumber(col4))
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
                  TsPrimaryKeyDef(name: 'uid', type: TsColumnType.integer)
                ]),
            reservedThroughput: tableCreateReservedThroughputDefault,
            tableOptions: tableCreateOptionsDefault);
        await client.createTable(tableName, description);
      }
    }

    test('createTable', () async {
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
            {'name': 'uid', 'type': 'integer'}
          ]
        },
        'reservedThroughput': {
          'capacityUnit': {'read': 0, 'write': 0}
        },
        'tableOptions': {'timeToLive': -1, 'maxVersions': 1}
      });
    });

    test('createWorkTable', () async {
      await createWorkTable(client);
      var tableDescription = await client.describeTable(workTable);
      var tableMeta = tableDescription.tableMeta;
      expect(tableMeta.toMap(), {
        'name': 'test_work2',
        'primaryKeys': [
          {'name': 'key1', 'type': 'string'},
          {'name': 'key2', 'type': 'integer'},
          {'name': 'key3', 'type': 'string'},
          {'name': 'key4', 'type': 'integer'}
        ]
      });
    });
  });
}
