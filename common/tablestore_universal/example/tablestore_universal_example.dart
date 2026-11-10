// ignore_for_file: avoid_print

import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

/// A table written and read on a fresh memory instance (every platform).
///
/// The same code on `tablestoreUniversal.client(options: ...)` reaches the
/// real Tablestore on nodejs (a sembast memory database on the Dart VM).
Future<void> main() async {
  var client = newTablestoreMemory().client();
  await client.createTable(
    'users',
    TsTableDescription(
      tableMeta: TsTableDescriptionTableMeta(
        tableName: 'users',
        primaryKeys: [TsPrimaryKeyDef(name: 'id', type: TsColumnType.string)],
      ),
      reservedThroughput: tableCreateReservedThroughputDefault,
      tableOptions: tableCreateOptionsDefault,
    ),
  );
  var key = TsPrimaryKey([TsKeyValue.string('id', 'u1')]);
  await client.putRow(
    TsPutRowRequest(
      tableName: 'users',
      primaryKey: key,
      data: TsAttributes([TsAttribute.string('name', 'Alice')]),
    ),
  );
  var response = await client.getRow(
    TsGetRowRequest(tableName: 'users', primaryKey: key),
  );
  print(response.row.attributes?.toMap()['name']?.value); // Alice
}
