// ignore_for_file: avoid_print

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';

Future<void> main() async {
  // An empty database; the credentials of TsClientOptions are not used.
  var client = newTablestoreSembastMemory().client();
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
      data: TsAttributes([
        TsAttribute.string('name', 'Alice'),
        TsAttribute.int('age', 42),
        TsAttribute.double('score', 4.5),
      ]),
    ),
  );
  var response = await client.getRow(
    TsGetRowRequest(tableName: 'users', primaryKey: key),
  );
  print(response.row.attributes?.toMap()['name']?.value); // Alice
}
