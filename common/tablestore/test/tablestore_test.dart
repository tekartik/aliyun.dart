import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:test/test.dart';

void main() {
  group('tablestore', () {
    test('public', () {
      // ignore: unnecessary_statements
      tsValueToDebugValue;
      // ignore: unnecessary_statements
      TsValueLong;
      // ignore: unnecessary_statements
      TsValue;
      // ignore: unnecessary_statements
      TsValueInfinite;
    });
    test('key', () {
      var key = TsPrimaryKeyDef();
      expect(key.toMap(), {});
      key = TsPrimaryKeyDef.fromMap(key.toMap());
      expect(key.toMap(), {});

      key = TsPrimaryKeyDef(
          name: 'id', type: TsColumnType.integer, autoIncrement: true);

      expect(key.toMap(),
          {'name': 'id', 'type': 'integer', 'autoIncrement': true});
      key = TsPrimaryKeyDef.fromMap(key.toMap());
      expect(key.toMap(),
          {'name': 'id', 'type': 'integer', 'autoIncrement': true});
    });
    test('table', () {
      var description = TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta(
              tableName: 'test_create1',
              primaryKeys: [
                TsPrimaryKeyDef(name: 'gid', type: TsColumnType.integer),
                TsPrimaryKeyDef(name: 'uid', type: TsColumnType.integer)
              ]),
          reservedThroughput: tableCreateReservedThroughputDefault,
          tableOptions: tableCreateOptionsDefault);
      expect(description.toMap(), {
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
  });
}
