import 'dart:typed_data';

import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:test/test.dart';

void main() {
  rowTest(tsClientTest);
}

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
          data: [TsAttribute('test', 'text')]));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKeys': [
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
          'primaryKeys': [
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
          data: [TsAttribute('test', 'text')]));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKeys': [
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
            data: [TsAttribute('test', 'text')]));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
        expect(e.retryable, isFalse);
      }

      response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          condition: TsCondition.ignore,
          primaryKey: key,
          data: [TsAttribute('test', 'text')]));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKeys': [
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
          data: [TsAttribute('test', 'text')]));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKeys': [
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
            data: [TsAttribute('test', 'text')]));
        fail('should fail');
      } on TsException catch (e) {
        expect(e.isConditionFailedError, isTrue);
      }
    });

    test('deleteRow', () async {
      await createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'deleteRow')]);
      // Put first
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: [TsAttribute('test', 'text')]));

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
          data: [TsAttribute.int('test', 1)]));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      var getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKeys': [
            {'key': 'long'}
          ],
          'attributes': [
            {'test': TsValueLong.fromNumber(1)}
          ]
        }
      });

      // max int 9007199254740991
      await client.putRow(
          TsPutRowRequest(tableName: keyStringTable, primaryKey: key, data: [
        TsAttribute.long('test', TsValueLong.fromString('90071992547409910'))
      ]));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKeys': [
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
          data: [TsAttribute.binary('test', buffer)]));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      var getResponse = await client
          .getRow(TsGetRowRequest(tableName: keyStringTable, primaryKey: key));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKeys': [
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

    test('range', () async {
      await createKeyStringTable();
      var key = TsPrimaryKey([TsKeyValue('key', 'range')]);
      await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKey: key,
          data: [TsAttribute.int('test', 1)]));

      // [{"columnName":"test","columnValue":{"buffer":[1,0,0,0,0,0,0,0],"offset":0},"timestamp":{"buffer":[34,112,237,99,116,1,0,0],"offset":0}}]},"RequestId":"0005aea6-5781-8d9d-2bc1-720b0a6d35ba"}
      var getResponse =
          await client.getRange(TsGetRangeRequest(tableName: keyStringTable));
      expect(getResponse.toDebugMap(), {
        'row': {
          'primaryKeys': [
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
    }, skip: true);
  });
}
