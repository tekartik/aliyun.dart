import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_exception.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_common.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_table_common.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_tablestore_common.dart';
import 'package:test/test.dart';

void main() {
  group('tablestore_node_common', () {
    test('toCreateTableParams', () {
      var description = TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta(
              tableName: 'test_create1',
              primaryKeys: [
                TsPrimaryKeyDef(name: 'gid', type: TsColumnType.integer),
                TsPrimaryKeyDef(name: 'uid', type: TsColumnType.integer)
              ]),
          reservedThroughput: tableCreateReservedThroughputDefault,
          tableOptions: tableCreateOptionsDefault);
      expect(toCreateTableParams(description), {
        'tableMeta': {
          'tableName': 'test_create1',
          'primaryKey': TsArrayHack([
            {'name': 'gid', 'type': 1},
            {'name': 'uid', 'type': 1}
          ])
        },
        'reservedThroughput': {
          'capacityUnit': {'read': 0, 'write': 0}
        },
        'tableOptions': {'timeToLive': -1, 'maxVersions': 1}
      });
    });

    test('toGetRowParams', () {
      var getRowRequest =
          TsGetRowRequest(tableName: null, primaryKey: null, columns: null);
      expect(toGetRowParams(getRowRequest), {});
      getRowRequest = TsGetRowRequest(
          tableName: 'test',
          primaryKey: TsPrimaryKey([TsKeyValue.int('key', 1)]));
      expect(toGetRowParams(getRowRequest), {
        'tableName': 'test',
        'primaryKey': [
          {'key': TsValueLong.fromNumber(1)}
        ]
      });
      getRowRequest = TsGetRowRequest(
          tableName: 'test',
          primaryKey: TsPrimaryKey([TsKeyValue.int('key', 1)]),
          columns: ['col1', 'col2']);
      expect(toGetRowParams(getRowRequest), {
        'tableName': 'test',
        'primaryKey': [
          {'key': TsValueLong.fromNumber(1)}
        ],
        'columnsToGet': ['col1', 'col2']
      });
    });

    test('toPutRowParams', () {
      var r = TsPutRowRequest(tableName: null, primaryKey: null, data: null);

      expect(toPutRowParams(r), {
        'condition': TsCondition.ignore,
        'returnContent': {'returnType': 1}
      });

      r = TsPutRowRequest(
          // Not supported for real...
          data: null,
          tableName: 'test',
          primaryKey: TsPrimaryKey([TsKeyValue.int('key', 1)]));
      expect(toPutRowParams(r), {
        'tableName': 'test',
        'condition': TsCondition.ignore,
        'primaryKey': [
          {'key': TsValueLong.fromNumber(1)},
        ],
        'returnContent': {'returnType': 1},
      });
      r = TsPutRowRequest(
          tableName: 'test',
          primaryKey: TsPrimaryKey([TsKeyValue.int('key', 1)]),
          data: TsAttributes(
              [TsAttribute.int('col1', 1), TsAttribute('col2', 'value')]));
      expect(toPutRowParams(r), {
        'condition': TsCondition.ignore,
        'tableName': 'test',
        'primaryKey': [
          {'key': TsValueLong.fromNumber(1)}
        ],
        'attributeColumns': [
          {'col1': TsValueLong.fromNumber(1)},
          {'col2': 'value'}
        ],
        'returnContent': {'returnType': 1}
      });
    });

    test('toUpdateRowParams', () {
      var r = TsUpdateRowRequest(tableName: null, primaryKey: null, data: null);

      expect(toUpdateRowParams(r), {
        'condition': TsCondition.expectExist,
        'returnContent': {'returnType': 1}
      });

      r = TsUpdateRowRequest(
          // Not supported for real...
          data: null,
          tableName: 'test',
          primaryKey: TsPrimaryKey([TsKeyValue.int('key', 1)]));
      expect(toUpdateRowParams(r), {
        'tableName': 'test',
        'condition': TsCondition.expectExist,
        'primaryKey': [
          {'key': TsValueLong.fromNumber(1)},
        ],
        'returnContent': {'returnType': 1},
      });
      r = TsUpdateRowRequest(
          tableName: 'test',
          primaryKey: TsPrimaryKey([TsKeyValue.int('key', 1)]),
          data: TsUpdateAttributes([
            TsUpdateAttributePut(TsAttributes(
                [TsAttribute.int('col1', 1), TsAttribute('col2', 'value')])),
            TsUpdateAttributeDelete(['col3', 'col4'])
          ]));
      expect(toUpdateRowParams(r), {
        'condition': TsCondition.expectExist,
        'tableName': 'test',
        'primaryKey': [
          {'key': TsValueLong.fromNumber(1)}
        ],
        'updateOfAttributeColumns': [
          {
            'PUT': [
              {'col1': TsValueLong.fromNumber(1)},
              {'col2': 'value'}
            ]
          },
          {
            'DELETE_ALL': TsArrayHack(['col3', 'col4'])
          }
        ],
        'returnContent': {'returnType': 1}
      });
    });

    test('Exception', () {
      var exception = TsExceptionNode(
          map: {'code': 403, 'message': '\u0017Condition check failed.'});
      expect(exception.isConditionFailedError, isTrue);
    });
  });
}
