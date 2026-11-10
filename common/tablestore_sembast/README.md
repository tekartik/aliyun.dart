# tekartik_aliyun_tablestore_sembast

An Aliyun Tablestore (OTS) implementation of the `tekartik_aliyun_tablestore`
API on a [sembast](https://pub.dev/packages/sembast) database: in memory for
tests, in a local file for an offline or development mode. No Aliyun account,
no network.

## Getting started

Git packages, not on pub.dev:

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

In memory ([example/main.dart](example/main.dart), `dart run example/main.dart`):

```dart
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
```

## Imports and platforms

| Import | Gives | Platforms |
|---|---|---|
| `package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart` | `newTablestoreSembastMemory()` (empty), `tablestoreSembastMemory` (shared), `getTablestoreSembast(factory:)` (any sembast factory) | every platform |
| `package:tekartik_aliyun_tablestore_sembast/tablestore_sembast_io.dart` | `tablestoreSembastIo`, `getTablestoreSembastIo(rootPath:)` (file database) | Dart VM, Flutter native |

Import `package:tekartik_aliyun_tablestore/tablestore.dart` too (requests,
`TsClient`, `TsClientOptions`): it is not re-exported.

## Common pitfalls

* The database is `TsClientOptions.instanceName` (default `default.db`): a
  relative name is opened under `.dart_tool/tekartik_aliyun/tablestore/` (of
  `rootPath` for `getTablestoreSembastIo`). Clients of the shared
  `tablestoreSembastMemory` with the same name share their tables: use
  `newTablestoreSembastMemory()` in tests.
* Call `getTablestoreSembast` once per sembast factory and keep the result.
* Attribute values: `String`, `TsValueLong` (`TsAttribute.int`), `double`,
  `Uint8List`; an unsupported type throws a `TsException`.
* Not supported: `startLocalTransaction` (`UnimplementedError`) and the `not`
  operator of a composite column condition (`UnsupportedError`).
* `deleteTable` of an unknown table throws (wrap a cleanup in `try`).

## Testing

```bash
dart test
```

The shared Tablestore suite (`tekartik_aliyun_tablestore_test`,
`tablestoreTest(client)`) runs on this implementation in
`test/tablestore_universal_test` of this repository.
