---
name: tekartik-aliyun-tablestore-tables
description: >-
  Use when connecting to Aliyun Tablestore (OTS) from Dart and managing tables
  with tekartik_aliyun_tablestore: the Tablestore factory, TsClient,
  TsClientOptions (accessKeyId, secretAccessKey, endpoint, instanceName),
  listTableNames, createTable, describeTable, deleteTable, TsTableDescription,
  TsTableDescriptionTableMeta, TsPrimaryKeyDef, TsColumnType,
  TsTableDescriptionOptions, TsTableDescriptionReservedThroughput,
  TsTableCapacityUnit, tableCreateOptionsDefault,
  tableCreateReservedThroughputDefault, tableCreateCapacityUnitDefault,
  TsException (isTableNotExistError), the
  package:tekartik_aliyun_tablestore/tablestore.dart import and running the
  shared tablestoreTest suite against an implementation.
---

# Tablestore client and tables (tekartik_aliyun_tablestore)

`tekartik_aliyun_tablestore` is the platform independent API of Aliyun
Tablestore (OTS): it declares `Tablestore`, `TsClient` and the request/response
model but contains no implementation. Pick an implementation package
(`tekartik_aliyun_tablestore_node` on nodejs,
`tekartik_aliyun_tablestore_sembast` for a local/mock database, or
`tekartik_aliyun_tablestore_universal` to get both) and code against this API.

## Guidelines

* Dependency (git, not published on pub.dev):
  ```yaml
  dependencies:
    tekartik_aliyun_tablestore:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/tablestore
      version: '>=0.2.3'
  ```
  In practice you depend on an implementation package as well; they all
  re-export this API, so a single `import
  'package:tekartik_aliyun_tablestore/tablestore.dart';` is enough for shared
  code.
* Everything public lives in the single library
  `package:tekartik_aliyun_tablestore/tablestore.dart`. Never import
  `src/...` directly; `src/mixin/ts_tablestore_mixin.dart` is only for
  packages implementing the API (`TsClientMixin`, `TablestoreMixin`,
  `TsValueBase`, `TsColumnSingleCondition`, `TsColumnCompositeCondition`,
  `TsComparatorType`, `TsLogicalOperator`).
* Get a client from a `Tablestore` instance:
  `tablestore.client(options: TsClientOptions(accessKeyId: ..., secretAccessKey: ..., endpoint: ..., instanceName: ...))`.
  `instanceName` is optional here but required by the real Aliyun service;
  mocks ignore the options. Write your own code against `TsClient`, not
  against a concrete implementation, so it can run on node and on a mock.
* Table admin on `TsClient`: `listTableNames()` (a `Future<List<String>>`,
  and `UnsupportedError` on implementations that do not support it),
  `createTable(name, description)`, `describeTable(name)` returning a
  `TsTableDescription`, `deleteTable(name)`.
* Build a `TsTableDescription` with a `TsTableDescriptionTableMeta`
  (`tableName` + the ordered `primaryKeys` list of `TsPrimaryKeyDef`), plus
  `reservedThroughput: tableCreateReservedThroughputDefault` (0 read / 0
  write, pay per request) and `tableOptions: tableCreateOptionsDefault`
  (`timeToLive: -1`, `maxVersions: 1`). Use
  `TsTableDescriptionReservedThroughput(capacityUnit: TsTableCapacityUnit(read: , write: ))`
  and `TsTableDescriptionOptions(timeToLive: , maxVersions: )` only when the
  defaults do not fit.
* `TsPrimaryKeyDef(name: , type: , autoIncrement: )` uses `TsColumnType.integer`,
  `TsColumnType.string` or `TsColumnType.binary`; `autoIncrement: true` is
  only valid for an `integer` key and never for the first (partition) key.
  The primary key order matters: it is the order of the values you pass in
  every `TsPrimaryKey` afterwards.
* `TsTableDescription`, `TsTableDescriptionTableMeta`, `TsPrimaryKeyDef`,
  `TsTableCapacityUnit`, `TsTableDescriptionOptions` and
  `TsTableDescriptionReservedThroughput` all have `toMap()` /
  `fromMap(Map)`, which is the easiest way to compare or log a schema
  (`describeTable(...).toMap()` returns the `tableMeta`/`reservedThroughput`/
  `tableOptions` keys and possibly more, so filter before comparing).
* Creating a table is rate limited and asynchronous on the real service:
  create once (check `listTableNames()` first), never per test, and never
  delete/recreate in a loop.
* Errors are `TsException`: check `isTableNotExistError`,
  `isConditionFailedError`, `isPrimaryKeySizeError`, `isPrimaryKeyTypeError`
  and `retryable` instead of parsing `message`.
* Testing: the repo ships `tekartik_aliyun_tablestore_test`
  (`git url: https://github.com/tekartik/aliyun.dart, path: test/tablestore_test`)
  exposing `tablestoreTest(TsClient client)`, the shared suite every
  implementation must pass. Run it against a mock client
  (`tekartik_aliyun_tablestore_sembast`) in unit tests.

## Examples

### Create a table if it does not exist yet

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

/// Single string partition key table, pay per request, no expiration.
Future<void> createKeyStringTable(TsClient client, String tableName) async {
  var names = await client.listTableNames();
  if (names.contains(tableName)) {
    return;
  }
  await client.createTable(
    tableName,
    TsTableDescription(
      tableMeta: TsTableDescriptionTableMeta(
        tableName: tableName,
        primaryKeys: [TsPrimaryKeyDef(name: 'key', type: TsColumnType.string)],
      ),
      reservedThroughput: tableCreateReservedThroughputDefault,
      tableOptions: tableCreateOptionsDefault,
    ),
  );
}
```

### Client from a Tablestore implementation, with explicit options

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

/// [tablestore] comes from an implementation package, for instance
/// `tablestoreServiceUniversal` (tekartik_aliyun_tablestore_universal) or
/// `getTablestoreSembast(...)` (tekartik_aliyun_tablestore_sembast).
TsClient openClient(
  Tablestore tablestore, {
  required String accessKeyId,
  required String secretAccessKey,
  required String endpoint,
  required String instanceName,
}) {
  return tablestore.client(
    options: TsClientOptions(
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
      endpoint: endpoint,
      instanceName: instanceName,
    ),
  );
}
```

### Multi key table with an auto increment key, and describe it

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

Future<void> createWorkTable(TsClient client) async {
  var tableName = 'test_work';
  if (!(await client.listTableNames()).contains(tableName)) {
    await client.createTable(
      tableName,
      TsTableDescription(
        tableMeta: TsTableDescriptionTableMeta(
          tableName: tableName,
          primaryKeys: [
            // Partition key first, never auto increment.
            TsPrimaryKeyDef(name: 'key1', type: TsColumnType.string),
            TsPrimaryKeyDef(name: 'key2', type: TsColumnType.integer),
            TsPrimaryKeyDef(
              name: 'key3',
              type: TsColumnType.integer,
              autoIncrement: true,
            ),
          ],
        ),
        reservedThroughput: TsTableDescriptionReservedThroughput(
          capacityUnit: TsTableCapacityUnit(read: 0, write: 0),
        ),
        tableOptions: TsTableDescriptionOptions(
          timeToLive: -1,
          maxVersions: 1,
        ),
      ),
    );
  }
  var description = await client.describeTable(tableName);
  print(description); // name test_work, primaryKeys: [pk(key1, string), ...]
  print(description.toMap());
}
```

### Delete a table, tolerating a missing one

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

Future<void> deleteTableIfExists(TsClient client, String tableName) async {
  try {
    await client.deleteTable(tableName);
  } on TsException catch (e) {
    if (!e.isTableNotExistError) {
      rethrow;
    }
  }
}
```

### Run the shared test suite against a client

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
// dev_dependency, git url: https://github.com/tekartik/aliyun.dart,
// path: test/tablestore_test
import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';
import 'package:test/test.dart';

/// [client] is null when the implementation is not configured
/// (missing credentials for instance): skip rather than fail.
void runSuite(TsClient? client) {
  group('my_implementation', () {
    tablestoreTest(client!);
  }, skip: client == null);
}
```
