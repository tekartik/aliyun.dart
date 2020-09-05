import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
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
                    TsPrimaryKey(name: 'key', type: TsColumnType.string),
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
      var keys = [TsKeyValue('key', 'value')];
      await createKeyStringTable();
      var response = await client.putRow(TsPutRowRequest(
          tableName: keyStringTable,
          primaryKeys: keys,
          data: [TsAttribute('test', 'text')]));
      expect(response.toDebugMap(), {
        'row': {
          'primaryKeys': [
            {'key': 'value'}
          ],
          'attributes': []
        }
      });

      var getResponse = await client.getRow(
          TsGetRowRequest(tableName: keyStringTable, primaryKeys: keys));
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
  });
}
