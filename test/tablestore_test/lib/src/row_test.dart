import 'dart:typed_data';

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:test/test.dart';

import 'table_test.dart';

void rowTest(TsClient client) {
  group('row', () {
    Future _createKeyStringTable() async {
      await createKeyStringTable(client);
    }

    test('describeTable', () async {
      // We are limited in the number of create, test it well and sometimes delete!
      await _createKeyStringTable();

      var tableDescription = await client.describeTable(keyStringTableName);
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
      await _createKeyStringTable();
      var response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
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
      var getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
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

    test('put/getRowColumns', () async {
      var key = TsPrimaryKey([TsKeyValue('key', 'get_row_columns')]);
      await _createKeyStringTable();
      var response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          data: TsAttributes([
            TsAttribute('test1', 'text1'),
            TsAttribute('test2', TsValueLong.fromNumber(1)),
            TsAttribute('test3', Uint8List.fromList([2]))
          ])));
      expect(response.toDebugMap(), {
        'row': {'primaryKey': key.toDebugList(), 'attributes': []}
      });

      // TSs: getRow {"tableName":"test_key_string","primaryKey":[{"key":"get_row_columns"}]}
      // TSr: {"consumed":{"capacityUnit":{"read":1,"write":0}},"row":
      // {"primaryKey":[{"name":"key","value":"get_row_columns"}],
      // "attributes":[
      //    {"columnName":"test1","columnValue":"text1","timestamp":{"buffer":[179,37,123,170,116,1,0,0],"offset":0}},
      //    {"columnName":"test2","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[179,37,123,170,116,1,0,0],"offset":0}},
      //    {"columnName":"test3","columnValue":[2],"timestamp":{"buffer":[179,37,123,170,116,1,0,0],"offset":0}}]},"RequestId":"0005afb9-f10e-60b2-a5c1-720b1bf9dfb2"}
      /*00:06 +1 ~1: test/tablestore_universal_test.dart: tablestore universal tablestore row put/getRowColumns
      TSs: getRow {"tableName":"test_key_string","primaryKey":[{"key":"get_row_columns"}],"columnsToGet":["missing","test1"]}
      00:06 +1 ~1: compiling test/tablestore_universal_test.dart
      TSr: {"consumed":{"capacityUnit":{"read":1,"write":0}},"row":{"primaryKey":[{"name":"key","value":"get_row_columns"}],"attributes":[{"columnName":"test1","columnValue":"text1","timestamp":{"buffer":[179,37,123,170,116,1,0,0],"offset":0}}]},"RequestId":"0005afb9-f111-90bb-2bc1-720b16336918"}
      00:06 +1 ~1: test/tablestore_universal_test.dart: tablestore universal tablestore row put/getRowColumns
      TSs: getRow {"tableName":"test_key_string","primaryKey":[{"key":"get_row_columns"}],"columnsToGet":["test2","test1"]}
      00:06 +1 ~1: compiling test/tablestore_universal_test.dart
      TSr: {"consumed":{"capacityUnit":{"read":1,"write":0}},"row":{"primaryKey":[{"name":"key","value":"get_row_columns"}],"attributes":[{"columnName":"test1","columnValue":"text1","timestamp":{"buffer":[179,37,123,170,116,1,0,0],"offset":0}},{"columnName":"test2","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[179,37,123,170,116,1,0,0],"offset":0}}]},"RequestId":"0005afb9-f114-7a78-a4c1-720b1a61284e"}
  */
      var getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(
          getResponse.row.attributes.map((attr) => attr.name).toList()..sort(),
          ['test1', 'test2', 'test3']);
      // With column
      getResponse = await client.getRow(TsGetRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          columns: ['missing', 'test1']));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': key.toDebugList(),
          'attributes': [
            {'test1': 'text1'}
          ]
        }
      });
      // Order might not be respected!
      getResponse = await client.getRow(TsGetRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          columns: ['test2', 'test1']));
      try {
        expect(getResponse.toDebugMap(), {
          'row': {
            'primaryKey': key.toDebugList(),
            'attributes': [
              {
                'test2': {'@long': '1'}
              },
              {'test1': 'text1'}
            ]
          }
        });
      } on TestFailure catch (_) {
        expect(getResponse.toDebugMap(), {
          'row': {
            'primaryKey': key.toDebugList(),
            'attributes': [
              {'test1': 'text1'},
              {
                'test2': {'@long': '1'}
              },
            ]
          }
        });
      }
      getResponse = await client.getRow(TsGetRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          columns: ['test1', 'test3']));
      try {
        expect(getResponse.toDebugMap(), {
          'row': {
            'primaryKey': key.toDebugList(),
            'attributes': [
              {'test1': 'text1'},
              {
                'test3': {'@blob': 'Ag=='}
              }
            ]
          }
        });
      } on TestFailure catch (_) {
        expect(getResponse.toDebugMap(), {
          'row': {
            'primaryKey': key.toDebugList(),
            'attributes': [
              {
                'test3': {'@blob': 'Ag=='}
              },
              {'test1': 'text1'},
            ]
          }
        });
      }
      // With no columns
      getResponse = await client.getRow(TsGetRowRequest(
          tableName: keyStringTableName, primaryKey: key, columns: []));
      // Implementation reads all attributes
      expect(getResponse.row.attributes.length, 3);

      // With key columns
      getResponse = await client.getRow(TsGetRowRequest(
          tableName: keyStringTableName, primaryKey: key, columns: ['key']));
      expect(getResponse.row.attributes.length, 0);
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
      await _createKeyStringTable();

      //  {"consumed":{"capacityUnit":{"read":1,"write":0}},"row":{},"RequestId":"0005af5a-da0c-7e1b-e6c1-720b15164f6e"}
      var response = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(response.row.primaryKey, isNull);
    });

    test('put/deleteRow', () async {
      var key = TsPrimaryKey([TsKeyValue('key', 'value')]);

      await _createKeyStringTable();
      var response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
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
          TsDeleteRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(deleteResponse.toDebugMap(), {});

      var getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(getResponse.row.primaryKey, isNull);
    });

    test('putRow', () async {
      await _createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'putRow')]);
      // Delete first
      await client.deleteRow(
          TsDeleteRowRequest(tableName: keyStringTableName, primaryKey: key));

      TsPutRowResponse response;
      try {
        await client.putRow(TsPutRowRequest(
            tableName: keyStringTableName,
            condition: TsCondition.expectExist,
            primaryKey: key,
            data: TsAttributes([TsAttribute('test', 'text')])));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
        expect(e.retryable, isFalse);
      }

      var badKey = TsPrimaryKey([TsKeyValue('key', TsValueLong.fromNumber(1))]);
      try {
        // TS!: errMap: {"message":"\n\fOTSInvalidPK\u0012:Validate PK type fail. Input: VT_INTEGER, Meta: VT_STRING.","code":400,"headers":{"date":"Wed, 16 Sep 2020 10:02:55 GMT","transfer-encoding":"chunked","connection":"keep-alive","authorization":"OTS LTAI4GCzUBNEhUsjDMwxrpHs:/3c02Jlku+fxqx506jh+WEP2paY=","x-ots-contentmd5":"F1dJ+CMsGH4Nc1DUKSWHQA==","x-ots-contenttype":"protocol buffer","x-ots-date":"2020-09-16T10:02:55.384181Z","x-ots-requestid":"0005af6b-5f18-e605-2bc1-720b17615fbe"},"time":{},"retryable":false}
        await client.putRow(TsPutRowRequest(
            tableName: keyStringTableName,
            primaryKey: badKey,
            data: TsAttributes([TsAttribute('test', 'text')])));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isPrimaryKeyTypeError, isTrue);
        expect(e.retryable, isFalse);
      }

      var nullKey = TsPrimaryKey([TsKeyValue('key', null)]);
      try {
        await client.putRow(TsPutRowRequest(
            tableName: keyStringTableName,
            primaryKey: nullKey,
            data: TsAttributes([TsAttribute('test', 'test')])));
        fail('should fail');
      } on TsException catch (e) {
        // expect(e.isPrimaryKeyTypeError, isTrue);
        expect(e.retryable, isFalse);
      }

      // Null value
      try {
        await client.putRow(TsPutRowRequest(
            tableName: keyStringTableName,
            primaryKey: key,
            data: TsAttributes([TsAttribute('test', null)])));
        fail('should fail');
      } on TsException catch (e) {
        // expect(e.isPrimaryKeyTypeError, isTrue);
        expect(e.retryable, isFalse);
      }

      // Null data
      response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName, primaryKey: key, data: null));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'putRow'}
          ],
          'attributes': []
        }
      });
      expect(
          (await client.getRow(TsGetRowRequest(
                  tableName: keyStringTableName, primaryKey: key)))
              .row
              .attributes
              .toDebugList(),
          []);

      response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
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
      expect(
          (await client.getRow(TsGetRowRequest(
                  tableName: keyStringTableName, primaryKey: key)))
              .row
              .attributes
              .toDebugList(),
          [
            {'test': 'text'}
          ]);
      expect(
          (await client.getRow(TsGetRowRequest(
                  tableName: keyStringTableName, primaryKey: key)))
              .row
              .attributes
              .toMap(),
          {'test': TsAttribute('test', 'text')});

      await _createKeyStringTable();
      response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
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
            tableName: keyStringTableName,
            condition: TsCondition.expectNotExist,
            primaryKey: key,
            data: TsAttributes([TsAttribute('test', 'text')])));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }
    });

    test('updateRow', () async {
      await _createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'updateRow')]);

      // Delete first
      await client.deleteRow(
          TsDeleteRowRequest(tableName: keyStringTableName, primaryKey: key));

      try {
        // Default should fail (fail if not exists is the default)
        await client.updateRow(TsUpdateRowRequest(
            tableName: keyStringTableName,
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

      // conditional update ok
      var response = await client.updateRow(TsUpdateRowRequest(
          tableName: keyStringTableName,
          condition: TsCondition(
              rowExistenceExpectation:
                  TsConditionRowExistenceExpectation.ignore,
              columnCondition: TsColumnCondition.lessThan(
                  'col1', TsValueLong.fromNumber(2))),
          primaryKey: key,
          data: TsUpdateAttributes([
            TsUpdateAttributePut(TsAttributes([TsAttribute.int('col1', 2)])),
          ])));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': []
        }
      });
      var getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': [
            {
              'col1': {'@long': '2'}
            },
            // {'col2': 'value'}, ?
          ]
        }
      });

      try {
        // conditional update failure
        response = await client.updateRow(TsUpdateRowRequest(
            tableName: keyStringTableName,
            condition: TsCondition(
                rowExistenceExpectation:
                    TsConditionRowExistenceExpectation.ignore,
                columnCondition: TsColumnCondition.lessThan(
                    'col1', TsValueLong.fromNumber(2))),
            primaryKey: key,
            data: TsUpdateAttributes([
              TsUpdateAttributePut(TsAttributes([TsAttribute.int('col1', 3)])),
            ])));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }
      expect(response.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': []
        }
      });
      getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': [
            {
              'col1': {'@long': '2'}
            },
            // {'col2': 'value'},
          ]
        }
      });
      // ignore: unused_local_variable
      response = await client.updateRow(TsUpdateRowRequest(
          tableName: keyStringTableName,
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
      getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': [
            {
              'col1': {'@long': '1'}
            },
            {'col2': 'value'},
          ]
        }
      });
      response = await client.updateRow(TsUpdateRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          data: TsUpdateAttributes([
            TsUpdateAttributePut(TsAttributes(
                [TsAttribute.int('col1', 2), TsAttribute.int('col4', 4)])),
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

      getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'updateRow'}
          ],
          'attributes': [
            {
              'col1': {'@long': '2'}
            },
            {
              'col4': {'@long': '4'}
            },
          ]
        }
      });
    });

    test('deleteRow', () async {
      await _createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'deleteRow')]);
      // Put first
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          data: TsAttributes([TsAttribute('test', 'text')])));

      TsDeleteRowResponse response;
      try {
        response = await client.deleteRow(TsDeleteRowRequest(
            tableName: keyStringTableName,
            condition: TsCondition.expectNotExist,
            primaryKey: key));

        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }

      response = await client.deleteRow(TsDeleteRowRequest(
          tableName: keyStringTableName,
          condition: TsCondition.expectExist,
          primaryKey: key));
      expect(response.toDebugMap(), {});

      try {
        response = await client.deleteRow(TsDeleteRowRequest(
            tableName: keyStringTableName,
            condition: TsCondition.expectExist,
            primaryKey: key));

        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }

      response = await client.deleteRow(TsDeleteRowRequest(
          tableName: keyStringTableName,
          condition: TsCondition.ignore,
          primaryKey: key));

      expect(response.toDebugMap(), {});
    });

    test('long', () async {
      await _createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'long')]);
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          data: TsAttributes([TsAttribute.int('test', 1)])));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      var getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'long'}
          ],
          'attributes': [
            {
              'test': {'@long': '1'}
            }
          ]
        }
      });

      // max int 9007199254740991
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          data: TsAttributes([
            TsAttribute.long(
                'test', TsValueLong.fromString('90071992547409910'))
          ])));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'long'}
          ],
          'attributes': [
            {
              'test': {'@long': '90071992547409910'}
            }
          ]
        }
      });
      expect(getResponse.toDebugMap()['row']['attributes'][0]['test'],
          {'@long': '90071992547409910'});

      expect(getResponse.row.attributes.first.name, 'test');
      var long = getResponse.row.attributes.first.value as TsValueLong;
      if (isRunningAsJavascript) {
        expect(TsValueLong.fromNumber(long.toNumber()).toString(),
            isNot('90071992547409910'));
      } else {
        expect(TsValueLong.fromNumber(long.toNumber()).toString(),
            '90071992547409910');
      }
    });

    test('binary', () async {
      await _createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'binary')]);
      var buffer = Uint8List.fromList([1, 2, 3]);
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTableName,
          primaryKey: key,
          data: TsAttributes([TsAttribute.binary('test', buffer)])));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      var getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKey': [
            {'key': 'binary'}
          ],
          'attributes': [
            {
              'test': {'@blob': 'AQID'}
            }
          ]
        }
      });
      expect(getResponse.toDebugMap()['row']['attributes'][0]['test'],
          {'@blob': 'AQID'});
      var binary = getResponse.row.attributes.first.value;
      expect(binary, const TypeMatcher<Uint8List>());
      expect(binary, buffer);
    });

    test('batch_read', () async {
      await _createKeyStringTable();

      // Put single
      var key1 = TsPrimaryKey([TsKeyValue('key', 'batch_1')]);
      var key2 = TsPrimaryKey([TsKeyValue('key', 'batch_2')]);
      //var key3 = TsPrimaryKey([TsKeyValue('key', 'batch_3')]);
      await client.putRow(
        TsPutRowRequest(
            tableName: keyStringTableName,
            primaryKey: key1,
            data: TsAttributes([TsAttribute.int('test', 1)])),
      );

      var response = await client.batchGetRows(TsBatchGetRowsRequest(tables: [
        TsBatchGetRowsRequestTable(
            tableName: keyStringTableName,
            primaryKeys: [key1],
            columns: ['test']),
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
                {
                  'test': {'@long': '1'}
                }
              ]
            },
          ]
        ]
      });

      response = await client.batchGetRows(TsBatchGetRowsRequest(tables: [
        TsBatchGetRowsRequestTable(
            tableName: keyStringTableName,
            primaryKeys: [key1, key2],
            columns: ['test']),
      ]));
    });

    test('batch_write', () async {
      await _createKeyStringTable();
      var key1 = TsPrimaryKey([TsKeyValue('key', 'batch_1')]);
      //var key2 = TsPrimaryKey([TsKeyValue('key', 'batch_2')]);
      //var key3 = TsPrimaryKey([TsKeyValue('key', 'batch_3')]);
      var response =
          await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(tableName: keyStringTableName, rows: [
          TsBatchWriteRowsRequestPutRow(
              primaryKey: key1,
              data: TsAttributes([TsAttribute.int('test', 1)])),
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

    test('batch_write_update_delete', () async {
      await _createKeyStringTable();
      var key1 = TsPrimaryKey([TsKeyValue('key', 'batch_write_update_delete')]);
      //var key2 = TsPrimaryKey([TsKeyValue('key', 'batch_2')]);
      //var key3 = TsPrimaryKey([TsKeyValue('key', 'batch_3')]);
      var response =
          await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(tableName: keyStringTableName, rows: [
          TsBatchWriteRowsRequestPutRow(
              primaryKey: key1,
              data: TsAttributes([TsAttribute.int('test', 1)])),
        ])
      ]));
      //devPrint(jsonPretty(response.toDebugMap()));
      expect(response.toDebugMap(), {
        'rows': [
          {
            'isOk': true,
            'tableName': 'test_key_string',
            'primaryKey': [
              {'key': 'batch_write_update_delete'}
            ],
            'attributes': []
          }
        ]
      });
      // update
      response = await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(tableName: keyStringTableName, rows: [
          TsBatchWriteRowsRequestUpdateRow(
              condition: TsCondition(
                  rowExistenceExpectation:
                      TsConditionRowExistenceExpectation.expectExist),
              primaryKey: key1,
              data: TsUpdateAttributes([
                TsUpdateAttributePut(TsAttributes([TsAttribute.int('test', 2)]))
              ]))
        ])
      ]));
      var getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key1));
      expect(getResponse.row.attributes.list.first, TsAttribute.int('test', 2));

      // conditional update
      response = await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(tableName: keyStringTableName, rows: [
          TsBatchWriteRowsRequestUpdateRow(
              condition: TsCondition(
                  rowExistenceExpectation:
                      TsConditionRowExistenceExpectation.expectExist,
                  columnCondition: TsColumnCondition.equals(
                      'test', TsValueLong.fromNumber(3))),
              primaryKey: key1,
              data: TsUpdateAttributes([
                TsUpdateAttributePut(TsAttributes([TsAttribute.int('test', 4)]))
              ]))
        ])
      ]));
      expect(response.rows.first.isOk, isFalse);
      expect(response.rows.first.tableName, keyStringTableName);
      /*
      expect(response.toDebugMap(), {
        'rows': [
          {
            'isOk': false,
            'errorMessage': 'Condition check failed.',
            'errorCode': 'OTSConditionCheckFail',
            'tableName': 'test_key_string'
          }
        ]
      });
       */
      getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key1));
      expect(getResponse.row.attributes.list.first, TsAttribute.int('test', 2));

      response = await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(
            tableName: keyStringTableName,
            rows: [TsBatchWriteRowsRequestDeleteRow(primaryKey: key1)])
      ]));
      //devPrint(jsonPretty(response.toDebugMap()));
      expect(response.toDebugMap(), {
        'rows': [
          {
            'isOk': true,
            'tableName': 'test_key_string',
            'primaryKey': [
              {'key': 'batch_write_update_delete'}
            ],
            'attributes': []
          }
        ]
      });
      getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTableName, primaryKey: key1));
      expect(getResponse.row.primaryKey, isNull);
    });

    test('no_batch', () async {
      await _createKeyStringTable();
      var key1 = TsPrimaryKey([TsKeyValue('key', 'batch_1')]);
      // var key2 = TsPrimaryKey([TsKeyValue('key', 'batch_2')]);
      // var key3 = TsPrimaryKey([TsKeyValue('key', 'batch_3')]);
      await client.putRow(
        TsPutRowRequest(
            tableName: keyStringTableName,
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
      await _createKeyStringTable();
      var key1 = TsPrimaryKey([TsKeyValue('key', 'range_1')]);
      var key2 = TsPrimaryKey([TsKeyValue('key', 'range_2')]);
      var key3 = TsPrimaryKey([TsKeyValue('key', 'range_3')]);
      await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
        TsBatchWriteRowsRequestTable(tableName: keyStringTableName, rows: [
          TsBatchWriteRowsRequestPutRow(
              primaryKey: key1,
              data: TsAttributes([TsAttribute.int('test', 1)])),
          TsBatchWriteRowsRequestPutRow(
              primaryKey: key2,
              data: TsAttributes([TsAttribute.int('test', 2)])),
          TsBatchWriteRowsRequestPutRow(
              primaryKey: key3,
              data: TsAttributes([TsAttribute.int('test', 3)])),
        ])
      ]));

      // {maxVersions: 1, limit: null, tableName: test_key_string, inclusiveStartPrimaryKey: [{key: INF_MIN}], exclusiveEndPrimaryKey: [{key: INF_MAX}], direction: TsDirection.forward}
      // TSs: getRange {"maxVersions":1,"limit":null,"tableName":"test_key_string","inclusiveStartPrimaryKey":[{"key":{}}],"exclusiveEndPrimaryKey":[{"key":{}}],"direction":"FORWARD"}
      // TSr: {"consumed":{"capacityUnit":{"read":1,"write":0}},"rows":[{"primaryKey":[{"name":"key","value":"binary"}],"attributes":[{"columnName":"test","columnValue":[1,2,3],"timestamp":{"buffer":[45,66,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"key1Js"}],"attributes":[{"columnName":"col1","columnValue":"表格存储","timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col2","columnValue":"2","timestamp":{"buffer":[28,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col3","columnValue":3.1,"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col4","columnValue":-0.32,"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}},{"columnName":"col5","columnValue":{"buffer":[21,205,91,7,0,0,0,0],"offset":0},"timestamp":{"buffer":[219,208,43,94,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"long"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[246,255,255,255,255,255,63,1],"offset":0},"timestamp":{"buffer":[159,64,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"putRow"}],"attributes":[{"columnName":"test","columnValue":"text","timestamp":{"buffer":[188,58,184,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"put_row"}],"attributes":[{"columnName":"test","columnValue":"text","timestamp":{"buffer":[202,100,64,98,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"range"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[23,255,189,103,116,1,0,0],"offset":0}}]},{"primaryKey":[{"name":"key","value":"range_1"}],"attributes":[{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[102,113,199,103,116,1,0,0],"offset":0}}]}],"nextStartPrimaryKey":null,"compressType":0,"dataBlockType":0,"nextToken":[],"RequestId":"0005aeb5-6315-e1be-a4c1-720b0bd8e513"}
      var response = await client.getRange(TsGetRangeRequest(
          tableName: keyStringTableName,
          inclusiveStartPrimaryKey:
              TsPrimaryKey([TsKeyValue('key', TsValueInfinite.min)]),
          exclusiveEndPrimaryKey:
              TsPrimaryKey([TsKeyValue('key', TsValueInfinite.max)])));
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
                {
                  'test': {'@long': '1'}
                }
              ]
            }
          ]);

      response = await client.getRange(TsGetRangeRequest(
          tableName: keyStringTableName,
          inclusiveStartPrimaryKey:
              TsPrimaryKey([TsKeyValue('key', 'range_2')]),
          exclusiveEndPrimaryKey:
              TsPrimaryKey([TsKeyValue('key', 'range_3')])));
      expect(response.rows.map((e) => e.toDebugMap()), [
        {
          'primaryKey': [
            {'key': 'range_2'}
          ],
          'attributes': [
            {
              'test': {'@long': '2'}
            }
          ]
        }
      ]);
    });

    group('getRangeComplex', () {
      var col1 = 'range_complex';
      var _dataWritten = false;
      Future _writeComplexData() async {
        if (!_dataWritten) {
          await createWorkTable(client);

          var key1 = getWorkTableKey(col1, 1, 'col3_1', 2);
          var key2 = getWorkTableKey(col1, 2, 'col3_2', 3);
          var key3 = getWorkTableKey(col1, 3, 'col3_1', 4);
          var key4 = getWorkTableKey('${col1}_', 4, 'col3_1', 4);

          await client.batchWriteRows(TsBatchWriteRowsRequest(tables: [
            TsBatchWriteRowsRequestTable(tableName: workTableName, rows: [
              TsBatchWriteRowsRequestPutRow(
                  primaryKey: key1,
                  data: TsAttributes([TsAttribute.int('test', 1)])),
              TsBatchWriteRowsRequestPutRow(
                  primaryKey: key2,
                  data: TsAttributes([TsAttribute.int('test', 2)])),
              TsBatchWriteRowsRequestPutRow(
                  primaryKey: key3,
                  data: TsAttributes([TsAttribute.int('test', 3)])),
              TsBatchWriteRowsRequestPutRow(
                  primaryKey: key4,
                  data: TsAttributes([TsAttribute.int('test', 4)])),
            ])
          ]));
          _dataWritten = true;
        }
      }

      test('range_complex_single_condition', () async {
        await _writeComplexData();

        var response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.min, 'col3_1', TsValueInfinite.min),
            exclusiveEndPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.max, 'col3_1', TsValueInfinite.max),
            columnCondition: TsColumnCondition.equals('key3', 'col3_1')));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '1'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '2'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '1'}
                }
              ]
            },
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '3'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '4'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '3'}
                }
              ]
            }
          ]
        });

        response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.min, 'col3_1', TsValueInfinite.min),
            exclusiveEndPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.max, 'col3_1', TsValueInfinite.max),
            columnCondition: TsColumnCondition.greaterThanOrEquals(
                'key4', TsValueLong.fromNumber(4))));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '3'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '4'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '3'}
                }
              ]
            }
          ]
        });
      });

      test('range_complex_composite_condition_1', () async {
        await _writeComplexData();

        var response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.min, 'col3_1', TsValueInfinite.min),
            exclusiveEndPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.max, 'col3_1', TsValueInfinite.max),
            columnCondition: TsColumnCondition.and([
              TsColumnCondition.equals('key3', 'col3_1'),
              TsColumnCondition.lessThan('key4', TsValueLong.fromNumber(4))
            ])));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {'key2': TsValueLong.fromNumber(1)},
                {'key3': 'col3_1'},
                {'key4': TsValueLong.fromNumber(2)}
              ],
              'attributes': [
                {'test': TsValueLong.fromNumber(1)}
              ]
            }
          ]
        });
      }, skip: true);

      test('range_complex_composite_condition_2', () async {
        await _writeComplexData();

        var response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.min, 'col3_1', TsValueInfinite.min),
            exclusiveEndPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.max, 'col3_1', TsValueInfinite.max),
            columnCondition: TsColumnCondition.or([
              TsColumnCondition.equals('key3', 'col3_1'),
              TsColumnCondition.equals('key3', 'col3_2')
              // TsColumnCondition.lessThan('key4', TsValueLong.fromNumber(4))
            ])));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {'key2': TsValueLong.fromNumber(1)},
                {'key3': 'col3_1'},
                {'key4': TsValueLong.fromNumber(2)}
              ],
              'attributes': [
                {'test': TsValueLong.fromNumber(1)}
              ]
            }
          ]
        });
      }, skip: true);

      /*
      test('range_complex_composite_condition_2', () async {
        await _writeComplexData();

        var response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            columns: ['test'],
            start: TsKeyStartBoundary(getWorkTableKey(
                col1, TsValueInfinite.min, 'col3_1', TsValueInfinite.min)),
            end: TsKeyEndBoundary(getWorkTableKey(
                col1, TsValueInfinite.max, 'col3_1', TsValueInfinite.max)),
            columnCondition: TsColumnCondition.and([
              TsColumnCondition.greaterThan('test', TsValueLong.fromNumber(1)),
              TsColumnCondition.lessThan('test', TsValueLong.fromNumber(4))
            ])));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {'key2': TsValueLong.fromNumber(1)},
                {'key3': 'col3_1'},
                {'key4': TsValueLong.fromNumber(2)}
              ],
              'attributes': [
                {'test': TsValueLong.fromNumber(1)}
              ]
            }
          ]
        });
      }, solo: true);
      */

      test('range_complex_boundary', () async {
        await _writeComplexData();

        try {
          // TS!: errMap: {"message":"\n\fOTSInvalidPK\u0012)Validate PK size fail. Input: 1, Meta: 4.","code":400,"headers":{"date":"Wed, 16 Sep 2020 09:19:28 GMT","transfer-encoding":"chunked","connection":"keep-alive","authorization":"OTS LTAI4GCzUBNEhUsjDMwxrpHs:afS7DTs7cbaW5GB9Y0nc6O4Dz/g=","x-ots-contentmd5":"yt20bZ4gpFhPvN3pJ2XhVQ==","x-ots-contenttype":"protocol buffer","x-ots-date":"2020-09-16T09:19:28.148462Z","x-ots-requestid":"0005af6a-c3b1-a316-a5c1-720b0f1ffbdf"},"time":{},"retryable":false}
          await client.getRange(TsGetRangeRequest(
              tableName: workTableName,
              inclusiveStartPrimaryKey: TsPrimaryKey([TsKeyValue('key', col1)]),
              exclusiveEndPrimaryKey:
                  TsPrimaryKey([TsKeyValue('col1', '${col1}_')])));
          fail('should fail');
        } on TsException catch (e) {
          expect(e.retryable, isFalse);
          expect(e.isPrimaryKeySizeError, isTrue);
          expect(e.isTableNotExistError, isFalse);
          expect(e.isConditionFailedError, isFalse);
        }

        var response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.min, 'col3_1', TsValueInfinite.min),
            exclusiveEndPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.max, 'col3_1', TsValueInfinite.max)));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '1'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '2'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '1'}
                }
              ]
            },
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '2'}
                },
                {'key3': 'col3_2'},
                {
                  'key4': {'@long': '3'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '2'}
                }
              ]
            },
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '3'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '4'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '3'}
                }
              ]
            }
          ]
        });

        response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1, TsValueLong.fromNumber(3), 'col3_1', TsValueInfinite.min),
            exclusiveEndPrimaryKey: getWorkTableKey('${col1}_',
                TsValueInfinite.min, 'col3_1', TsValueInfinite.max)));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '3'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '4'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '3'}
                }
              ]
            }
          ]
        });

        response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1, TsValueLong.fromNumber(3), 'col3_1', TsValueInfinite.max),
            exclusiveEndPrimaryKey: getWorkTableKey('${col1}_',
                TsValueInfinite.max, 'col3_1', TsValueInfinite.max)));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex_'},
                {
                  'key2': {'@long': '4'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '4'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '4'}
                }
              ]
            }
          ]
        });

        response = await client.getRange(TsGetRangeRequest(
            tableName: workTableName,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1,
                TsValueLong.fromNumber(3),
                TsValueInfinite.min,
                TsValueInfinite.min),
            exclusiveEndPrimaryKey: getWorkTableKey(
                col1,
                TsValueLong.fromNumber(3),
                TsValueInfinite.max,
                TsValueInfinite.max)));
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '3'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '4'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '3'}
                }
              ]
            }
          ]
        });

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

      test('range_complex_limit', () async {
        await _writeComplexData();

        var request = TsGetRangeRequest(
            tableName: workTableName,
            limit: 1,
            inclusiveStartPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.min, 'col3_1', TsValueInfinite.min),
            exclusiveEndPrimaryKey: getWorkTableKey(
                col1, TsValueInfinite.max, 'col3_1', TsValueInfinite.max));
        var response = await client.getRange(request);
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '1'}
                },
                {'key3': 'col3_1'},
                {
                  'key4': {'@long': '2'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '1'}
                }
              ]
            }
          ],
          'nextStartPrimaryKey': [
            {'key1': 'range_complex'},
            {
              'key2': {'@long': '2'}
            },
            {'key3': 'col3_2'},
            {
              'key4': {'@long': '3'}
            }
          ]
        });

        request.inclusiveStartPrimaryKey = response.nextStartPrimaryKey;
        response = await client.getRange(request);
        expect(response.toDebugMap(), {
          'rows': [
            {
              'primaryKey': [
                {'key1': 'range_complex'},
                {
                  'key2': {'@long': '2'}
                },
                {'key3': 'col3_2'},
                {
                  'key4': {'@long': '3'}
                }
              ],
              'attributes': [
                {
                  'test': {'@long': '2'}
                }
              ]
            },
          ],
          'nextStartPrimaryKey': [
            {'key1': 'range_complex'},
            {
              'key2': {'@long': '3'}
            },
            {'key3': 'col3_1'},
            {
              'key4': {'@long': '4'}
            }
          ]
        });
      });
    });

    test('transaction1', () async {
      await _createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'transaction')]);
      await client.putRow(
        TsPutRowRequest(
            tableName: keyStringTableName,
            primaryKey: key,
            data: TsAttributes([TsAttribute.int('test', 1)])),
      );
      await client.startLocalTransaction(TsStartLocalTransactionRequest(
          tableName: keyStringTableName, primaryKey: key));
      // devPrint(jsonPretty(response.toDebugMap()));
    }, skip: true);

    test('transaction2', () async {
      await createTable1(client);
      var key = TsPrimaryKey([TsKeyValue('gid', TsValueLong.fromNumber(1))]);
      await client.startLocalTransaction(TsStartLocalTransactionRequest(
          tableName: twoKeysTable, primaryKey: key));
      // devPrint(jsonPretty(response.toDebugMap()));
    }, skip: true);
  });
}
