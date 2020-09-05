import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_common.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_table_common.dart';
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

    test('toGetRowParams', () {
      var getRowRequest =
          TsGetRowRequest(tableName: null, primaryKeys: null, columns: null);
      expect(toGetRowParams(getRowRequest), {});
      getRowRequest = TsGetRowRequest(
          tableName: 'test', primaryKeys: [TsPrimaryKeyValue('key', 1)]);
      expect(toGetRowParams(getRowRequest), {
        'tableName': 'test',
        'primaryKey': [
          {'key': 1}
        ]
      });
      getRowRequest = TsGetRowRequest(
          tableName: 'test',
          primaryKeys: [TsPrimaryKeyValue('key', 1)],
          columns: ['col1', 'col2']);
      expect(toGetRowParams(getRowRequest), {
        'tableName': 'test',
        'primaryKey': [
          {'key': 1}
        ],
        'columnsToGet': ['col1', 'col2']
      });
    });

    test('toPutRowParams', () {
      var r = TsPutRowRequest(tableName: null, primaryKeys: null, data: null);

      expect(toPutRowParams(r), {
        'returnContent': {'returnType': 1}
      });

      r = TsPutRowRequest(
          tableName: 'test', primaryKeys: [TsPrimaryKeyValue('key', 1)]);
      expect(toPutRowParams(r), {
        'tableName': 'test',
        'primaryKey': [
          {'key': 1}
        ],
        'returnContent': {'returnType': 1}
      });
      r = TsPutRowRequest(
          tableName: 'test',
          primaryKeys: [TsPrimaryKeyValue('key', 1)],
          data: {'col1': 1, 'col2': 'value'});
      expect(toPutRowParams(r), {
        'tableName': 'test',
        'primaryKey': [
          {'key': 1}
        ],
        'attributeColumns': {'col1': 1, 'col2': 'value'},
        'returnContent': {'returnType': 1}
      });
    });
  });
}
