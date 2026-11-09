# tekartik_aliyun_tablestore

The runtime independent API of Aliyun Tablestore (OTS): `Tablestore`,
`TsClient` (tables, rows, ranges, batches, conditions). No implementation
here: `tekartik_aliyun_tablestore_node` uses the Aliyun SDK on nodejs,
`tekartik_aliyun_tablestore_sembast` a sembast database (memory or io, for
tests and local runs), `tekartik_aliyun_tablestore_universal` picks one.

## Getting started

Git packages, not on pub.dev (a pub workspace, `path` required):

```yaml
dependencies:
  tekartik_aliyun_tablestore:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/tablestore
  tekartik_aliyun_tablestore_sembast:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/tablestore_sembast
```

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';

Future<void> main() async {
  // In memory; on nodejs: tablestoreNode.client(options: TsClientOptions(...)).
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
      data: TsAttributes([TsAttribute.string('name', 'Alice')]),
    ),
  );
  var response = await client.getRow(
    TsGetRowRequest(tableName: 'users', primaryKey: key),
  );
  print(response.row.attributes?.toMap()['name']?.value); // Alice
}
```

## Common pitfalls

* `TsClientOptions` holds the access key secret: read it from the
  environment, never from the source (its `toString` shows the endpoint
  only).
* An integer is a `TsValueLong` (`TsKeyValue.int`, `TsAttribute.int`): a
  plain Dart `int` value is not supported (only an assert catches it, in
  debug mode).
* Create a table once (it is slow and rate limited on Aliyun), not per
  test.
* Errors are `TsException` (`isConditionFailedError`,
  `isTableNotExistError`...).

More: the skills [tekartik-aliyun-tablestore-tables](skills/tekartik-aliyun-tablestore-tables/SKILL.md)
and [tekartik-aliyun-tablestore-rows](skills/tekartik-aliyun-tablestore-rows/SKILL.md).
