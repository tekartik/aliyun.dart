---
name: tekartik-aliyun-tablestore-sembast-setup
description: >-
  Use when you need a local, offline implementation of the Aliyun Tablestore
  API for tests, tooling or development with tekartik_aliyun_tablestore_sembast:
  tablestoreSembastMemory, newTablestoreSembastMemory, getTablestoreSembast
  (any sembast DatabaseFactory), tablestoreSembastIo and getTablestoreSembastIo
  from tablestore_sembast_io.dart, wiring TsClientOptions (instanceName as the
  sembast database path), using the resulting TsClient with the standard
  tekartik_aliyun_tablestore requests, and running the shared tablestoreTest
  suite on it.
---

# Sembast backed Tablestore mock (tekartik_aliyun_tablestore_sembast)

`tekartik_aliyun_tablestore_sembast` implements the
`tekartik_aliyun_tablestore` API (`Tablestore`, `TsClient`) on top of a
[sembast](https://pub.dev/packages/sembast) database: in memory for unit
tests, or a local file for a dev/offline mode. No Aliyun account, no network.

## Guidelines

* Dependency (git, not published on pub.dev). It is usually a
  `dev_dependency` since production code talks to the real service:
  ```yaml
  dev_dependencies:
    tekartik_aliyun_tablestore_sembast:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/tablestore_sembast
      version: '>=0.2.3'
  ```
* Two public libraries:
  * `package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart`
    (any platform): `tablestoreSembastMemory` (a single shared in memory
    instance), `newTablestoreSembastMemory()` (a fresh, isolated one) and
    `getTablestoreSembast(factory: <sembast DatabaseFactory>)`.
  * `package:tekartik_aliyun_tablestore_sembast/tablestore_sembast_io.dart`
    (Dart VM only, pulls `sembast/sembast_io.dart`): `tablestoreSembastIo`
    and `getTablestoreSembastIo({String? rootPath})` for a file backed
    database.
  It does not re-export `tekartik_aliyun_tablestore`, so import
  `package:tekartik_aliyun_tablestore/tablestore.dart` too for `TsClient`,
  `TsClientOptions` and the request classes.
* Call `getTablestoreSembast` / `getTablestoreSembastIo` **once per factory**
  and keep the returned `Tablestore`; then `tablestore.client(options: ...)`.
* `TsClientOptions` is still required by the API but its credentials are
  ignored: pass empty strings for `accessKeyId`/`secretAccessKey` and any
  label as `endpoint`. Only `instanceName` matters - it is the sembast
  database path. A relative name (the default `default.db`) is opened under
  `.dart_tool/tekartik_aliyun/tablestore/`; an absolute path is used as is.
  Use a distinct `instanceName` per test file to avoid sharing state, or
  `newTablestoreSembastMemory()` for a guaranteed empty database.
* Opening a database prints a `[SBi] Opening <path>` line; that is expected.
* Behaviour matches the shared suite for tables, `putRow`, `getRow`,
  `updateRow`, `deleteRow`, `getRange`, `batchGetRows` and `batchWriteRows`,
  including `TsCondition`, `TsColumnCondition`, `TsValueLong`,
  `TsValueInfinite` boundaries and per row `isOk` on batches. Failures are
  `TsException` with `isTableNotExistError` / `isConditionFailedError` set.
* Not supported: `startLocalTransaction` throws `UnimplementedError`, and
  `TsLogicalOperator.not` in a composite column condition throws
  `UnsupportedError`. Do not write shared code that relies on them.
* `createTable` requires `name == description.tableMeta!.tableName`
  (otherwise `ArgumentError`), and `deleteTable` throws when the table is
  unknown - wrap it in a `try` when cleaning up.
* Testing: with `tekartik_aliyun_tablestore_test`
  (`git url: https://github.com/tekartik/aliyun.dart, path: test/tablestore_test`)
  run the full shared suite - `tablestoreTest(client)` - against a memory
  client; that is how the implementation is validated.

## Examples

### Unit test on an isolated in memory instance

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';
import 'package:test/test.dart';

void main() {
  late TsClient client;

  setUp(() {
    // A brand new empty database for every test.
    var tablestore = newTablestoreSembastMemory();
    client = tablestore.client(
      options: TsClientOptions(
        endpoint: 'sembast',
        accessKeyId: '',
        secretAccessKey: '',
      ),
    );
  });

  test('put/getRow', () async {
    var tableName = 'test_key_string';
    await client.createTable(
      tableName,
      TsTableDescription(
        tableMeta: TsTableDescriptionTableMeta(
          tableName: tableName,
          primaryKeys: [
            TsPrimaryKeyDef(name: 'key', type: TsColumnType.string),
          ],
        ),
        reservedThroughput: tableCreateReservedThroughputDefault,
        tableOptions: tableCreateOptionsDefault,
      ),
    );
    expect(await client.listTableNames(), contains(tableName));

    var key = TsPrimaryKey([TsKeyValue.string('key', 'value')]);
    await client.putRow(
      TsPutRowRequest(
        tableName: tableName,
        primaryKey: key,
        data: TsAttributes([TsAttribute.string('test', 'text')]),
      ),
    );
    var response = await client.getRow(
      TsGetRowRequest(tableName: tableName, primaryKey: key),
    );
    expect(response.toDebugMap(), {
      'row': {
        'primaryKey': [
          {'key': 'value'},
        ],
        'attributes': [
          {'test': 'text'},
        ],
      },
    });
  });
}
```

### Shared memory instance, one database per test file

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';

/// `tablestoreSembastMemory` is shared: give each caller its own
/// `instanceName` so the data does not leak from one suite to the other.
TsClient memoryClient(String instanceName) {
  return tablestoreSembastMemory.client(
    options: TsClientOptions(
      endpoint: 'sembast',
      accessKeyId: '',
      secretAccessKey: '',
      instanceName: instanceName,
    ),
  );
}
```

### File backed client on the Dart VM

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast_io.dart';

Future<void> main() async {
  // Database at .local/tablestore/dev.db
  var tablestore = getTablestoreSembastIo(rootPath: '.local/tablestore');
  var client = tablestore.client(
    options: TsClientOptions(
      endpoint: 'sembast',
      accessKeyId: '',
      secretAccessKey: '',
      instanceName: 'dev.db',
    ),
  );
  // tablestoreSembastIo (no rootPath) resolves relative names under
  // .dart_tool/tekartik_aliyun/tablestore/ of the current directory.
  print(await client.listTableNames());
}
```

### Any sembast factory (web, encrypted, custom)

```dart
import 'package:sembast/sembast.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';

/// Call once per factory and cache the result.
Tablestore tablestoreFor(DatabaseFactory factory) =>
    getTablestoreSembast(factory: factory);
```

### Run the shared tablestore test suite on the mock

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
// dev_dependency, git url: https://github.com/tekartik/aliyun.dart,
// path: test/tablestore_test
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';
import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';

void main() {
  var client = newTablestoreSembastMemory().client(
    options: TsClientOptions(
      endpoint: 'sembast',
      accessKeyId: '',
      secretAccessKey: '',
      instanceName: 'shared_suite.db',
    ),
  );
  // The whole shared suite: tables, rows, ranges, batches.
  tablestoreTest(client);
}
```
