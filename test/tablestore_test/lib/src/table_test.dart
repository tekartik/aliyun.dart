import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:test/test.dart';

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

    var workTable = 'test_work2';

    Future createWorkTable() async {
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
    }

    test('createWorkTable', () async {
      await createWorkTable();
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
