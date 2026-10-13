import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';
import 'package:test/test.dart';

TsTableDescription _description(String name) => TsTableDescription(
  tableMeta: TsTableDescriptionTableMeta(
    tableName: name,
    primaryKeys: [TsPrimaryKeyDef(name: 'key', type: TsColumnType.string)],
  ),
  reservedThroughput: tableCreateReservedThroughputDefault,
  tableOptions: tableCreateOptionsDefault,
);

TsPrimaryKey _key(Object value) => TsPrimaryKey([TsKeyValue('key', value)]);

void main() {
  late TsClient client;
  var tableName = 'test';

  setUp(() async {
    client = newTablestoreSembastMemory().client();
    await client.createTable(tableName, _description(tableName));
  });

  Future<void> putRow(String key, List<TsAttribute> attributes) async {
    await client.putRow(
      TsPutRowRequest(
        tableName: tableName,
        primaryKey: _key(key),
        data: TsAttributes(attributes),
      ),
    );
  }

  Future<List<Object?>?> getAttributes(String key) async {
    var response = await client.getRow(
      TsGetRowRequest(tableName: tableName, primaryKey: _key(key)),
    );
    return response.row.attributes?.toDebugList();
  }

  test('deleteTable existing table', () async {
    await putRow('k1', [TsAttribute('a', 'A')]);
    await client.deleteTable(tableName);
    expect(await client.listTableNames(), isNot(contains(tableName)));
    await expectLater(
      client.describeTable(tableName),
      throwsA(isA<TsException>()),
    );

    // Recreated, it is empty
    await client.createTable(tableName, _description(tableName));
    var response = await client.getRange(
      TsGetRangeRequest(tableName: tableName),
    );
    expect(response.rows, isEmpty);
  });

  test('batch update keeps the other attributes', () async {
    await putRow('k1', [TsAttribute('a', 'A'), TsAttribute('b', 'B')]);
    await client.batchWriteRows(
      TsBatchWriteRowsRequest(
        tables: [
          TsBatchWriteRowsRequestTable(
            tableName: tableName,
            rows: [
              TsBatchWriteRowsRequestUpdateRow(
                primaryKey: _key('k1'),
                condition: TsCondition.expectExist,
                data: TsUpdateAttributes([
                  TsUpdateAttributePut(TsAttributes([TsAttribute('b', 'B2')])),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
    expect(await getAttributes('k1'), [
      {'a': 'A'},
      {'b': 'B2'},
    ]);
  });

  test('updateRow', () async {
    await putRow('k1', [TsAttribute('a', 'A'), TsAttribute('b', 'B')]);
    await client.updateRow(
      TsUpdateRowRequest(
        tableName: tableName,
        primaryKey: _key('k1'),
        data: TsUpdateAttributes([
          TsUpdateAttributePut(TsAttributes([TsAttribute('b', 'B2')])),
          TsUpdateAttributeDelete(['a']),
        ]),
      ),
    );
    expect(await getAttributes('k1'), [
      {'b': 'B2'},
    ]);
  });

  test('batch delete of a missing row', () async {
    var response = await client.batchWriteRows(
      TsBatchWriteRowsRequest(
        tables: [
          TsBatchWriteRowsRequestTable(
            tableName: tableName,
            rows: [TsBatchWriteRowsRequestDeleteRow(primaryKey: _key('none'))],
          ),
        ],
      ),
    );
    expect(response.rows.single.isOk, isTrue);
  });

  test('batchGetRows missing row', () async {
    await putRow('k1', [TsAttribute('a', 'A')]);
    var response = await client.batchGetRows(
      TsBatchGetRowsRequest(
        tables: [
          TsBatchGetRowsRequestTable(
            tableName: tableName,
            primaryKeys: [_key('k1'), _key('missing')],
          ),
        ],
      ),
    );
    var rows = response.tables.single;
    expect(rows[0].primaryKey?.toDebugList(), [
      {'key': 'k1'},
    ]);
    // Like the real service: no primary key, no attributes
    expect(rows[1].isOk, isTrue);
    expect(rows[1].primaryKey, isNull);
    expect(rows[1].attributes, isNull);
  });

  test('and/or column conditions', () async {
    await putRow('k1', [TsAttribute('a', 'A'), TsAttribute('b', 'B')]);
    await putRow('k2', [TsAttribute('a', 'A'), TsAttribute('b', 'C')]);
    await putRow('k3', [TsAttribute('a', 'D'), TsAttribute('b', 'C')]);
    Future<List<Object?>> keys(TsColumnCondition condition) async {
      var response = await client.getRange(
        TsGetRangeRequest(tableName: tableName, columnCondition: condition),
      );
      return response.rows
          .map((row) => row.primaryKey!.list.first.value)
          .toList();
    }

    expect(
      await keys(
        TsColumnCondition.and([
          TsColumnCondition.equals('a', 'A'),
          TsColumnCondition.equals('b', 'C'),
        ]),
      ),
      ['k2'],
    );
    expect(
      await keys(
        TsColumnCondition.or([
          TsColumnCondition.equals('b', 'B'),
          TsColumnCondition.equals('a', 'D'),
        ]),
      ),
      ['k1', 'k3'],
    );
  });

  group('range direction', () {
    setUp(() async {
      for (var key in ['a', 'b', 'c', 'd']) {
        await putRow(key, [TsAttribute('v', key)]);
      }
    });

    Future<List<Object?>> keys(TsGetRangeRequest request) async {
      var response = await client.getRange(request);
      return response.rows
          .map((row) => row.primaryKey!.list.first.value)
          .toList();
    }

    test('backward', () async {
      expect(
        await keys(
          TsGetRangeRequest(
            tableName: tableName,
            direction: TsDirection.backward,
            inclusiveStartPrimaryKey: _key(TsValueInfinite.max),
            exclusiveEndPrimaryKey: _key(TsValueInfinite.min),
          ),
        ),
        ['d', 'c', 'b', 'a'],
      );
      // Start inclusive, end exclusive
      expect(
        await keys(
          TsGetRangeRequest(
            tableName: tableName,
            direction: TsDirection.backward,
            inclusiveStartPrimaryKey: _key('c'),
            exclusiveEndPrimaryKey: _key('a'),
          ),
        ),
        ['c', 'b'],
      );
    });

    test('backward limit', () async {
      var response = await client.getRange(
        TsGetRangeRequest(
          tableName: tableName,
          direction: TsDirection.backward,
          limit: 1,
        ),
      );
      expect(response.rows.single.primaryKey!.list.first.value, 'd');
      expect(response.nextStartPrimaryKey!.list.first.value, 'c');
    });

    test('forward', () async {
      expect(
        await keys(
          TsGetRangeRequest(
            tableName: tableName,
            inclusiveStartPrimaryKey: _key('b'),
            exclusiveEndPrimaryKey: _key('d'),
          ),
        ),
        ['b', 'c'],
      );
      expect(
        await keys(
          TsGetRangeRequest(
            tableName: tableName,
            inclusiveStartPrimaryKey: _key(TsValueInfinite.min),
            exclusiveEndPrimaryKey: _key(TsValueInfinite.max),
          ),
        ),
        ['a', 'b', 'c', 'd'],
      );
    });
  });
}
