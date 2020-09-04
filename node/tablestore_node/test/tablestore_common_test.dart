import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_table.dart';
import 'package:test/test.dart';

void main() {
  group('tablestore_node_common', () {
    test('toCreateTableParams', () {
      var description = TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta(
              tableName: 'test_create1',
              primaryKeys: [
                TsPrimaryKey(name: 'gid', type: TsColumnType.integer),
                TsPrimaryKey(name: 'uid', type: TsColumnType.integer)
              ]),
          reservedThroughput: tableCreateReservedThroughputDefault,
          tableOptions: tableCreateOptionsDefault);
      expect(toCreateTableParams(description), {
        'tableMeta': {
          'tableName': 'test_create1',
          'primaryKey': [
            {'name': 'gid', 'type': 1},
            {'name': 'uid', 'type': 1}
          ]
        },
        'reservedThroughput': {
          'capacityUnit': {'read': 0, 'write': 0}
        },
        'tableOptions': {'timeToLive': -1, 'maxVersions': 1}
      });
    });
  });
}
