import 'dart:typed_data';

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:test/test.dart';
import 'table_test.dart';

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

    test('getRow missing table', () async {
      var key = TsPrimaryKey([TsKeyValue('key', 'value')]);

      try {
        // OTSParameterInvalidRequest table not exist, code: 400,
        await client.getRow(TsGetRowRequest(
            tableName: 'dummy_table_that_should_not_exist', primaryKey: key));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isTableNotExistError, isTrue);
        expect(e.isPrimaryKeySizeError, isFalse);
        expect(e.isConditionFailedError, isFalse);
        expect(e.retryable, isFalse);
      }
    });

    test('getRow missing record', () async {
      var key =
          TsPrimaryKey([TsKeyValue('key', 'dummy_key_that_should_not_exist')]);
      await createKeyStringTable();

      //  {"consumed":{"capacityUnit":{"read":1,"write":0}},"row":{},"RequestId":"0005af5a-da0c-7e1b-e6c1-720b15164f6e"}
      var response = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(response.row.primaryKey, isNull);
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

      try {
        // Default should fail (fail if not exists is the default)
        await client.updateRow(TsUpdateRowRequest(
            tableName: keyStringTable,
            primaryKey: key,
            data: TsUpdateAttributes([
              TsUpdateAttributePut(TsAttributes(
                  [TsAttribute.int('col1', 1), TsAttribute('col2', 'value')])),
              TsUpdateAttributeDelete(['col3', 'col4'])
            ])));
        fail('should fail');
      } on TsException catch (e) {
        // {"message":"\n\u0015OTSConditionCheckFail\u0012\u0017Condition check failed.","code":403,"headers":{"date":"Wed, 09 Sep 2020 08:37:11 GMT","transfer-encoding":"chunked","connection":"keep-alive","authorization":"OTS LTAI4GCzUBNEhUsjDMwxrpHs:ezio+sryJpqj7sF4aadRZtfCGTI=","x-ots-contentmd5":"tb1xxFT1i9oAap/9e+zMLA==","x-ots-contenttype":"protocol buffer","x-ots-date":"2020-09-09T08:37:11.680616Z","x-ots-requestid":"0005aedd-5b9e-9b48-a5c1-720b12a7b4bb"},"time":{},"retryable":false}
        expect(e.isConditionFailedError, isTrue);
      }

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
            TsUpdateAttributeDelete(['col3', 'col4'])
          ])));
      // {"consumed":{"capacityUnit":{"read":0,"write":1}},"row":{"primaryKey":[{"name":"key","value":"updateRow"}],"attributes":[]},"RequestId":"0005aedd-6a42-4f3f-e6c1-720b0a4a5a80"}
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': []
        }
      });

      // {"consumed":{"capacityUnit":{"read":0,"write":1}},"row":{"primaryKey":[{"name":"key","value":"updateRow"}],"attributes":[]},"RequestId":"0005aecc-876c-4878-a4c1-720b0ea2c3fd"}
      var getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': [
            {'col1': TsValueLong.fromNumber(1)},
            {'col2': 'value'},
          ]
        }
      });
      response = await client.updateRow(TsUpdateRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: TsUpdateAttributes([
            TsUpdateAttributePut(TsAttributes(
                [TsAttribute.int('col1', 2), TsAttribute.int('col4', 2)])),
            TsUpdateAttributeDelete(['col2', 'col3'])
          ])));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': []
        }
      });

      getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': [
            {'col1': TsValueLong.fromNumber(2)},
            {'col4': TsValueLong.fromNumber(2)},
          ]
        }
      });
    });

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

    test('range_simple', () async {
      await createKeyStringTable();
      var key1 = TsPrimaryKey([TsKeyValue('key', 'range_1')]);
      var key2 = TsPrimaryKey([TsKeyValue('key', 'range_2')]);
      var key3 = TsPrimaryKey([TsKeyValue('key', 'range_3')]);
      await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(tableName: keyStringTable, rows: [
          TsBatchWriteRowsRequestRow(
              type: TsWriteRowType.put,
              primaryKey: key1,
              data: [TsAttribute.int('test', 1)]),
          TsBatchWriteRowsRequestRow(
              type: TsWriteRowType.put,
              primaryKey: key2,
              data: [TsAttribute.int('test', 2)]),
          TsBatchWriteRowsRequestRow(
              type: TsWriteRowType.put,
              primaryKey: key3,
              data: [TsAttribute.int('test', 3)]),
        ])
      ]));

      // {maxVersions: 1, limit: null, tableName: test_key_string, inclusiveStartPrimaryKey: [{key: INF_MIN}], exclusiveEndPrimaryKey: [{key: INF_MAX}], direction: TsDirection.forward}
      // TSs: getRange {"maxVersions":1,"limit":null,"tableName":"test_key_string","inclusiveStartPrimaryKey":[{"key":{}}],"exclusiveEndPrimaryKey":[{"key":{}}],"direction":"FORWARD"}
      // TSr: {"consumed":{"capacityUnit":{"read":1,"write":0}},"rows":[{"primaryKey":[{"name":"key","value":"binary"}],"attributes":[{"columnName":"test","columnValue":[1,2,3],"timestamp":{"buffer":[45,66,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"key1Js"}],"attributes":[{"columnName":"col1","columnValue":"表格存储","timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col2","columnValue":"2","timestamp":{"buffer":[28,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col3","columnValue":3.1,"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col4","columnValue":-0.32,"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col5","columnValue":{"buffer":[21,205,91,7,0,0,0,0],"offset":0},"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"long"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[246,255,255,255,255,255,63,1],"offset":0},"timestamp":{"buffer":[159,64,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"putRow"}],"attributes":[{"columnName":"test","columnValue":"text","timestamp":{"buffer":[188,58,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"put_row"}],"attributes":[{"columnName":"test","columnValue":"text","timestamp":{"buffer":[202,100,64,98,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"range"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[23,255,189,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"range_1"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[102,113,199,103,116,1,0,0],"offset":0}}]}],"nextStartPrimaryKey":null,"compressType":0,"dataBlockType":0,"nextToken":[],"RequestId":"0005aeb5-6315-e1be-a4c1-720b0bd8e513"}
      var response = await client.getRange(TsGetRangeRequest(
          tableName: keyStringTable,
          start: TsKeyStartBoundary(
              TsPrimaryKey([TsKeyValue('key', TsValueInfinite.min)])),
          end: TsKeyEndBoundary(
              TsPrimaryKey([TsKeyValue('key', TsValueInfinite.max)]))));
      expect(
          response.rows
              .where(
                  (element) => element.primaryKey.list.first.value == 'range_1')
              .map((e) => e.toDebugMap()),
          [
            {
              'primaryKey': [
                {'key': 'range_1'}
              ],
              'attributes': [
                {'test': TsValueLong.fromNumber(1)}
              ]
            }
          ]);

      response = await client.getRange(TsGetRangeRequest(
          tableName: keyStringTable,
          start:
              TsKeyStartBoundary(TsPrimaryKey([TsKeyValue('key', 'range_2')])),
          end: TsKeyEndBoundary(TsPrimaryKey([TsKeyValue('key', 'range_3')]))));
      expect(response.rows.map((e) => e.toDebugMap()), [
        {
          'primaryKey': [
            {'key': 'range_2'}
          ],
          'attributes': [
            {'test': TsValueLong.fromNumber(2)}
          ]
        }
      ]);
    });

    test('range_complex', () async {
      await createWorkTable(client);
      var col1 = 'range_complex';

      var key1 = getWorkTableKey(col1, 1, 'path_1', 2);
      var key2 = getWorkTableKey(col1, 2, 'path_2', 3);
      var key3 = getWorkTableKey(col1, 3, 'path_1', 4);
      var key4 = getWorkTableKey('${col1}_', 4, 'path_1', 4);

      await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(tableName: workTable, rows: [
          TsBatchWriteRowsRequestRow(
              type: TsWriteRowType.put,
              primaryKey: key1,
              data: [TsAttribute.int('test', 1)]),
          TsBatchWriteRowsRequestRow(
              type: TsWriteRowType.put,
              primaryKey: key2,
              data: [TsAttribute.int('test', 2)]),
          TsBatchWriteRowsRequestRow(
              type: TsWriteRowType.put,
              primaryKey: key3,
              data: [TsAttribute.int('test', 3)]),
          TsBatchWriteRowsRequestRow(
              type: TsWriteRowType.put,
              primaryKey: key4,
              data: [TsAttribute.int('test', 4)]),
        ])
      ]));

      try {
        // TS!: errMap: {"message":"\n\fOTSInvalidPK\u0012)Validate PK size fail. Input: 1, Meta: 4.","code":400,"headers":{"date":"Wed, 16 Sep 2020 09:19:28 GMT","transfer-encoding":"chunked","connection":"keep-alive","authorization":"OTS LTAI4GCzUBNEhUsjDMwxrpHs:afS7DTs7cbaW5GB9Y0nc6O4Dz/g=","x-ots-contentmd5":"yt20bZ4gpFhPvN3pJ2XhVQ==","x-ots-contenttype":"protocol buffer","x-ots-date":"2020-09-16T09:19:28.148462Z","x-ots-requestid":"0005af6a-c3b1-a316-a5c1-720b0f1ffbdf"},"time":{},"retryable":false}
        await client.getRange(TsGetRangeRequest(
            tableName: workTable,
            start: TsKeyStartBoundary(TsPrimaryKey([TsKeyValue('key', col1)])),
            end: TsKeyEndBoundary(
                TsPrimaryKey([TsKeyValue('col1', '${col1}_')]))));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.retryable, isFalse);
        expect(e.isPrimaryKeySizeError, isTrue);
        expect(e.isTableNotExistError, isFalse);
        expect(e.isConditionFailedError, isFalse);
      }
      /*
      expect(
          response.rows
              .where(
                  (element) => element.primaryKey.list.first.value == 'range_1')
              .map((e) => e.toDebugMap()),
          [
            {
              'primaryKey': [
                {'key': 'range_1'}
              ],
              'attributes': [
                {'test': TsValueLong.fromNumber(1)}
              ]
            }
          ]);

      response = await client.getRange(TsGetRangeRequest(
          tableName: keyStringTable,
          start:
              TsKeyStartBoundary(TsPrimaryKey([TsKeyValue('key', 'range_2')])),
          end: TsKeyEndBoundary(TsPrimaryKey([TsKeyValue('key', 'range_3')]))));
      expect(response.rows.map((e) => e.toDebugMap()), [
        {
          'primaryKey': [
            {'key': 'range_2'}
          ],
          'attributes': [
            {'test': TsValueLong.fromNumber(2)}
          ]
        }
      ]);

       */
    });

    test('transaction1', () async {
      await createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'transaction')]);
      await client.putRow(
        TsPutRowRequest(
            tableName: keyStringTable,
            primaryKey: key,
            data: TsAttributes([TsAttribute.int('test', 1)])),
      );
      await client.startLocalTransaction(TsStartLocalTransactionRequest(
          tableName: keyStringTable, primaryKey: key));
      // devPrint(jsonPretty(response.toDebugMap()));
    }, skip: true);

    test('transaction2', () async {
      await createTable1(client);
      var key = TsPrimaryKey([TsKeyValue('gid', TsValueLong.fromNumber(1))]);
      await client.startLocalTransaction(TsStartLocalTransactionRequest(
          tableName: table1Name, primaryKey: key));
      // devPrint(jsonPretty(response.toDebugMap()));
    }, skip: true);
  });
}
