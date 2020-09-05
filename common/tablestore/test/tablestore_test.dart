import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:test/test.dart';

void main() {
  group('tablestore', () {
    test('key', () {
      var key = TsPrimaryKey();
      expect(key.toMap(), {});
      key = TsPrimaryKey.fromMap(key.toMap());
      expect(key.toMap(), {});

      key = TsPrimaryKey(
          name: 'id', type: TsColumnType.integer, autoIncrement: true);

      expect(key.toMap(),
          {'name': 'id', 'type': 'integer', 'autoIncrement': true});
      key = TsPrimaryKey.fromMap(key.toMap());
      expect(key.toMap(),
          {'name': 'id', 'type': 'integer', 'autoIncrement': true});
    });
    test('table', () {
      var description = TsTableDescription(
          tableMeta: TsTableDescriptionTableMeta(
              tableName: 'test_create1',
              primaryKeys: [
                TsPrimaryKey(name: 'gid', type: TsColumnType.integer),
                TsPrimaryKey(name: 'uid', type: TsColumnType.integer)
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
