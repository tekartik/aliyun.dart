# tekartik_aliyun_tablestore_universal

One Aliyun Tablestore (OTS) for code that runs both on the Dart VM and on
nodejs: `tablestoreUniversal` is the real service over the `tablestore` npm
module when compiled to JavaScript for node (`tekartik_aliyun_tablestore_node`,
typically in a Function Compute function), and a sembast database on the Dart
VM (`tekartik_aliyun_tablestore_sembast`). The whole
`tekartik_aliyun_tablestore` API is re-exported.

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_aliyun_tablestore_universal:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/tablestore_universal
```

For node, a `package.json` with `"tablestore": "^5.0.7"` and `npm install`.

A table on a fresh memory instance
([example/tablestore_universal_example.dart](example/tablestore_universal_example.dart)):

```dart
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

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
```

The deployed code uses `tablestoreUniversal.client(options:
TsClientOptions(endpoint: ..., accessKeyId: ..., secretAccessKey: ...,
instanceName: ...))`. `package:tekartik_aliyun_tablestore_universal/environment_client.dart`
reads them from the environment (`tsClientOptionsFromEnv`, null with a
printed message when one is missing on node).

## Platforms

* nodejs (dart2js): `tablestoreUniversal` is `tablestoreNode`.
* Dart VM: `tablestoreUniversal` is a shared sembast memory database;
  `getTablestore(localRootPath: ...)` a sembast file database.
* `newTablestoreMemory()`: a fresh memory database, every platform.
* Browser: not supported.

## Common pitfalls

* On the VM `tablestoreUniversal` keeps nothing between runs: use
  `getTablestore(localRootPath: '.dart_tool/tablestore')` for a local
  database that persists (ignored on node).
* The mock does not implement `startLocalTransaction` nor the `not`
  composite column condition.
* The real service rate limits `createTable`: create a table once, guarded
  by `listTableNames()`.
* Credentials: environment variables on node, the process_run user config
  (`.local/ds_env.yaml`, git-ignored) on the VM; never commit them.

## Testing

```bash
dart test           # vm (mock) and node (dart_test.yaml platforms)
```

The shared suite is `tekartik_aliyun_tablestore_test` (`test/tablestore_test`
in this repository, run on this package by `test/tablestore_universal_test`).
