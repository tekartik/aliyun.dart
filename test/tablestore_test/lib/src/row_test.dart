import 'dart:typed_data';

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:test/test.dart';

void rowTest(TsClient client) {
  group('row', () {
    var keyStringTable = 'test_key_string';
    var keyStringTableCreated = false;
    Future createKeyStringTable() async {
      if (!keyStringTableCreated) {
        // We are limited in the number of create, test it well and sometimes delete!
        var tableName = keyStringTable;
        var names = await client.listTableNames();
        if (!names.contains(tableName)) {
          var description = TsTableDescription(
              tableMeta: TsTableDescriptionTableMeta(
                  tableName: keyStringTable,
                  primaryKeys: [
                    TsPrimaryKeyDef(name: 'key', type: TsColumnType.string),
                  ]),
              reservedThroughput: tableCreateReservedThroughputDefault,
              tableOptions: tableCreateOptionsDefault);
          await client.createTable(tableName, description);
        }
        keyStringTableCreated = true;
      }
    }

    test('describeTable', () async {
      // We are limited in the number of create, test it well and sometimes delete!
      await createKeyStringTable();

      var tableDescription = await client.describeTable(keyStringTable);
      var keys = ['tableMeta', 'tableOptions', 'reservedThroughput'];
      var map = tableDescription.toMap()
        ..removeWhere((key, value) => !keys.contains(key));
      expect(map, {
        'tableMeta': {
          'name': 'test_key_string',
          'primaryKeys': [
            {'name': 'key', 'type': 'string'}
          ]
        },
        'reservedThroughput': {
          'capacityUnit': {'read': 0, 'write': 0}
        },
        'tableOptions': {'timeToLive': -1, 'maxVersions': 1}
      });
    });

    test('put/getRow', () async {
      var key = TsPrimaryKey([TsKeyValue('key', 'value')]);
      await createKeyStringTable();
      var response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'value'}
          ],
          'attributes': []
        }
      });

      // [{"columnName":"test","columnValue":"text","timestamp":{"buffer":[176,8,239,99,116,1,0,0],"offset":0}}]},
      var getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'value'}
          ],
          'attributes': [
            {'test': 'text'}
          ]
        }
      });
    });

    test('put/deleteRow', () async {
      var key = TsPrimaryKey([TsKeyValue('key', 'value')]);

      await createKeyStringTable();
      var response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'value'}
          ],
          'attributes': []
        }
      });

      var deleteResponse = await client.deleteRow(
          TsDeleteRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(deleteResponse.toDebugMap(), {});
    });

    test('putRow', () async {
      await createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'putRow')]);
      // Delete first
      await client.deleteRow(
          TsDeleteRowRequest(tableName: keyStringTable, primaryKey: key));

      TsPutRowResponse response;
      try {
        response = await client.putRow(TsPutRowRequest(
            tableName: keyStringTable,
            condition: TsCondition.expectExist,
            primaryKey: key,
            data: TsAttributes([TsAttribute('test', 'text')])));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
        expect(e.retryable, isFalse);
      }

      response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          condition: TsCondition.ignore,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'putRow'}
          ],
          'attributes': []
        }
      });

      await createKeyStringTable();
      response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          condition: TsCondition.ignore,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'putRow'}
          ],
          'attributes': []
        }
      });

      try {
        response = await client.putRow(TsPutRowRequest(
            tableName: keyStringTable,
            condition: TsCondition.expectNotExist,
            primaryKey: key,
            data: TsAttributes([TsAttribute('test', 'text')])));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }
    });

    test('updateRow', () async {
      await createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'updateRow')]);

      // Delete first
      await client.deleteRow(
          TsDeleteRowRequest(tableName: keyStringTable, primaryKey: key));

      /*
      try {
        // Default should faild (fail if not exists is the default
        await client.updateRow(TsUpdateRowRequest(
            tableName: keyStringTable,
            primaryKey: key,
            data: TsUpdateAttributes([
              TsUpdateAttributePut(TsAttributes(
                  [TsAttribute.int('col1', 1), TsAttribute('col2', 'value')])),
              TsUpdateAttributeDelete(['col3', 'col4'])
            ])));
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }*/

      // Tmp try to create first - remove if needed
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          condition: TsCondition.ignore,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));

      // ignore: unused_local_variable
      var response = await client.updateRow(TsUpdateRowRequest(
          tableName: keyStringTable,
          condition: TsCondition(
              rowExistenceExpectation:
                  TsConditionRowExistenceExpectation.ignore),
          primaryKey: key,
          data: TsUpdateAttributes([
            TsUpdateAttributePut(TsAttributes(
                [TsAttribute.int('col1', 1), TsAttribute('col2', 'value')])),
            // TsUpdateAttributeDelete(['col3', 'col4'])
          ])));

      // {"consumed":{"capacityUnit":{"read":0,"write":1}},"row":{"primaryKey":[{"name":"key","value":"updateRow"}],"attributes":[]},"RequestId":"0005aecc-876c-4878-a4c1-720b0ea2c3fd"}
      var getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'value'}
          ],
          'attributes': [
            {'col1': TsValueLong.fromNumber(1)},
            {'col2': 'value'},
            {'test': 'text'}
          ]
        }
      });

      /*  data: TsUpdateAttributes([
            TsUpdateAttributePut(TsAttributes(
                [TsAttribute.int('col1', 1), TsAttribute('col2', 'value')])),
            TsUpdateAttributeDelete(['col3', 'col4'])*/
      /*
      TsPutRowResponse response;
      try {
        response = await client.putRow(TsPutRowRequest(
            tableName: keyStringTable,
            condition: TsCondition.expectExist,
            primaryKey: key,
            data: TsAttributes([TsAttribute('test', 'text')])));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
        expect(e.retryable, isFalse);
      }

      response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          condition: TsCondition.ignore,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'putRow'}
          ],
          'attributes': []
        }
      });

      await createKeyStringTable();
      response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          condition: TsCondition.ignore,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'putRow'}
          ],
          'attributes': []
        }
      });

      try {
        response = await client.putRow(TsPutRowRequest(
            tableName: keyStringTable,
            condition: TsCondition.expectNotExist,
            primaryKey: key,
            data: TsAttributes([TsAttribute('test', 'text')])));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }

       */
    }, skip: true);

    test('deleteRow', () async {
      await createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'deleteRow')]);
      // Put first
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));

      TsDeleteRowResponse response;
      try {
        response = await client.deleteRow(TsDeleteRowRequest(
            tableName: keyStringTable,
            condition: TsCondition.expectNotExist,
            primaryKey: key));

        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }

      response = await client.deleteRow(TsDeleteRowRequest(
          tableName: keyStringTable,
          condition: TsCondition.expectExist,
          primaryKey: key));
      expect(response.toDebugMap(), {});

      try {
        response = await client.deleteRow(TsDeleteRowRequest(
            tableName: keyStringTable,
            condition: TsCondition.expectExist,
            primaryKey: key));

        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }

      response = await client.deleteRow(TsDeleteRowRequest(
          tableName: keyStringTable,
          condition: TsCondition.ignore,
          primaryKey: key));

      expect(response.toDebugMap(), {});
    });

    test('long', () async {
      await createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'long')]);
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: TsAttributes([TsAttribute.int('test', 1)])));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      var getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'long'}
          ],
          'attributes': [
            {'test': TsValueLong.fromNumber(1)}
          ]
        }
      });

      // max int 9007199254740991
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: TsAttributes([
            TsAttribute.long(
                'test', TsValueLong.fromString('90071992547409910'))
          ])));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'long'}
          ],
          'attributes': [
            {'test': TsValueLong.fromString('90071992547409910')}
          ]
        }
      });
      var long = getResponse.toDebugMap()['row']['attributes'][0]['test']
          as TsValueLong;
      if (isRunningAsJavascript) {
        expect(TsValueLong.fromNumber(long.toNumber()).toString(),
            isNot('90071992547409910'));
      } else {
        expect(TsValueLong.fromNumber(long.toNumber()).toString(),
            '90071992547409910');
      }
    });

    test('binary', () async {
      await createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'binary')]);
      var buffer = Uint8List.fromList([1, 2, 3]);
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: TsAttributes([TsAttribute.binary('test', buffer)])));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      var getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'binary'}
          ],
          'attributes': [
            {
              'test': [1, 2, 3]
            }
          ]
        }
      });
      var binary = getResponse.toDebugMap()['row']['attributes'][0]['test'];
      expect(binary, const TypeMatcher<Uint8List>());
    });

    test('batch_read', () async {
      await createKeyStringTable();

      // Put single
      var key1 = TsPrimaryKey([TsKeyValue('key', 'batch_1')]);
      var key2 = TsPrimaryKey([TsKeyValue('key', 'batch_2')]);
      //var key3 = TsPrimaryKey([TsKeyValue('key', 'batch_3')]);
      await client.putRow(
        TsPutRowRequest(
            tableName: keyStringTable,
            primaryKey: key1,
            data: TsAttributes([TsAttribute.int('test', 1)])),
      );

      var response = await client.batchGetRows(TsBatchGetRowsRequest(tables: [
        TsBatchGetRowsRequestTable(
            tableName: keyStringTable, primaryKeys: [key1], columns: ['test']),
      ]));

      // devPrint(jsonPretty(response.toDebugMap()));
      expect(response.toDebugMap(), {
        'tables': [
          [
            {
              'isOk': true,
              'tableName': 'test_key_string',
              'primaryKey': [
                {'key': 'batch_1'}
              ],
              'attributes': [
                {'test': TsValueLong.fromNumber(1)}
              ]
            },
          ]
        ]
      });

      response = await client.batchGetRows(TsBatchGetRowsRequest(tables: [
        TsBatchGetRowsRequestTable(
            tableName: keyStringTable,
            primaryKeys: [key1, key2],
            columns: ['test']),
      ]));
    });

    test('batch_write', () async {
      await createKeyStringTable();
      var key1 = TsPrimaryKey([TsKeyValue('key', 'batch_1')]);
      //var key2 = TsPrimaryKey([TsKeyValue('key', 'batch_2')]);
      //var key3 = TsPrimaryKey([TsKeyValue('key', 'batch_3')]);
      var response =
          await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(tableName: keyStringTable, rows: [
          TsBatchWriteRowsRequestRow(
              type: TsWriteRowType.put,
              primaryKey: key1,
              data: [TsAttribute.int('test', 1)]),
        ])
      ]));
      //devPrint(jsonPretty(response.toDebugMap()));
      expect(response.toDebugMap(), {
        'rows': [
          {
            'isOk': true,
            'tableName': 'test_key_string',
            'primaryKey': [
              {'key': 'batch_1'}
            ],
            'attributes': []
          }
        ]
      });

      /*
      BatchWriteRowResponse {
  tables:
   [ { isOk: true,
       errorCode: null,
       errorMessage: null,
       tableName: 'sampleTable',
       capacityUnit: [CapacityUnit],
       primaryKey: [Array],
       attributes: [] },
     { isOk: true,
       errorCode: null,
       errorMessage: null,
       tableName: 'sampleTable',
       capacityUnit: [CapacityUnit],
       primaryKey: [Array],
       attributes: [] } ],
  RequestId: '0005aebb-8f18-0f8b-e6c1-720b0b29242f' }

       */
    });

    test('no_batch', () async {
      await createKeyStringTable();
      var key1 = TsPrimaryKey([TsKeyValue('key', 'batch_1')]);
      // var key2 = TsPrimaryKey([TsKeyValue('key', 'batch_2')]);
      // var key3 = TsPrimaryKey([TsKeyValue('key', 'batch_3')]);
      await client.putRow(
        TsPutRowRequest(
            tableName: keyStringTable,
            primaryKey: key1,
            data: TsAttributes([TsAttribute.int('test', 1)])),
      );
      /*
      BatchWriteRowResponse {
  tables:
   [ { isOk: true,
       errorCode: null,
       errorMessage: null,
       tableName: 'sampleTable',
       capacityUnit: [CapacityUnit],
       primaryKey: [Array],
       attributes: [] },
     { isOk: true,
       errorCode: null,
       errorMessage: null,
       tableName: 'sampleTable',
       capacityUnit: [CapacityUnit],
       primaryKey: [Array],
       attributes: [] } ],
  RequestId: '0005aebb-8f18-0f8b-e6c1-720b0b29242f' }

       */
    }, skip: true);

    test('range', () async {
      await createKeyStringTable();
      var key1 = TsPrimaryKey([TsKeyValue('key', 'range_1')]);
      // var key2 = TsPrimaryKey([TsKeyValue('key', 'range_2')]);
      // var key3 = TsPrimaryKey([TsKeyValue('key', 'range_3')]);
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key1,
          data: TsAttributes([TsAttribute.int('test', 1)])));

      // {maxVersions: 1, limit: null, tableName: test_key_string, inclusiveStartPrimaryKey: [{key: INF_MIN}], exclusiveEndPrimaryKey: [{key: INF_MAX}], direction: TsDirection.forward}
      // TSs: getRange {"maxVersions":1,"limit":null,"tableName":"test_key_string","inclusiveStartPrimaryKey":[{"key":{}}],"exclusiveEndPrimaryKey":[{"key":{}}],"direction":"FORWARD"}
      // TSr: {"consumed":{"capacityUnit":{"read":1,"write":0}},"rows":[{"primaryKey":[{"name":"key","value":"binary"}],"attributes":[{"columnName":"test","columnValue":[1,2,3],"timestamp":{"buffer":[45,66,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"key1Js"}],"attributes":[{"columnName":"col1","columnValue":"表格存储","timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col2","columnValue":"2","timestamp":{"buffer":[28,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col3","columnValue":3.1,"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col4","columnValue":-0.32,"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col5","columnValue":{"buffer":[21,205,91,7,0,0,0,0],"offset":0},"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"long"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[246,255,255,255,255,255,63,1],"offset":0},"timestamp":{"buffer":[159,64,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"putRow"}],"attributes":[{"columnName":"test","columnValue":"text","timestamp":{"buffer":[188,58,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"put_row"}],"attributes":[{"columnName":"test","columnValue":"text","timestamp":{"buffer":[202,100,64,98,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"range"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[23,255,189,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"range_1"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[102,113,199,103,116,1,0,0],"offset":0}}]}],"nextStartPrimaryKey":null,"compressType":0,"dataBlockType":0,"nextToken":[],"RequestId":"0005aeb5-6315-e1be-a4c1-720b0bd8e513"}
      var response = await client.getRange(TsGetRangeRequest(
          tableName: keyStringTable,
          start: TsKeyBoundary(
              TsPrimaryKey([TsKeyValue('key', TsValueInfinite.min)]), true),
          end: TsKeyBoundary(
              TsPrimaryKey([TsKeyValue('key', TsValueInfinite.max)]), false)));
      expect(
          response.rows
              .where(
                  (element) => element.primaryKey.list.first.value == 'range_1')
              .map((e) => e.toDebugMap()),
          [
            {
              'primaryKeys': [
                {'key': 'range_1'}
              ],
              'attributes': [
                {'test': TsValueLong.fromNumber(1)}
              ]
            }
          ]);
    }, skip: true);
  });
}
