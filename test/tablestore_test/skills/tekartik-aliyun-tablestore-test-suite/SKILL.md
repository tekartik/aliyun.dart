---
name: tekartik-aliyun-tablestore-test-suite
description: >-
  Use when validating an implementation of the tekartik_aliyun_tablestore API
  (node, sembast mock, universal or your own) against the shared conformance
  suite of tekartik_aliyun_tablestore_test: the single entry point
  tablestoreTest(TsClient client) from
  package:tekartik_aliyun_tablestore_test/tablestore_test.dart, the row and
  table groups it declares, the test_key_string / test_work / test_create /
  test_create1 / create_table_N tables it creates, skipping the suite when no
  client is configured, and adding it as a dev_dependency with the git block
  path test/tablestore_test.
---

# Shared Tablestore conformance suite (tekartik_aliyun_tablestore_test)

`tekartik_aliyun_tablestore_test` contains no production code: it is the one
shared `package:test` suite that every implementation of the
`tekartik_aliyun_tablestore` API must pass (the real service on nodejs, the
sembast mock, the universal wrapper, or your own `TsClient`).

## Guidelines

* Dev dependency (git, not published on pub.dev):
  ```yaml
  dev_dependencies:
    tekartik_aliyun_tablestore_test:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: test/tablestore_test
    test: '>=1.31.0'
  ```
  Always a `dev_dependencies` entry: the package declares `test` and
  `dev_build` as regular dependencies, so depending on it from `dependencies`
  drags `package:test` into your shipped code.
* One public library, one entry point:
  ```dart
  import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';
  // void tablestoreTest(TsClient client)
  ```
  Nothing else is exported. `lib/src/row_test.dart` and
  `lib/src/table_test.dart` (`createKeyStringTable`, `createWorkTable`,
  `getWorkTableKey`, `keyStringTableName`, `workTableName`, `twoKeysTable`)
  are internal: never import `src/...`.
* `tablestoreTest(client)` **declares** tests, it does not run them: call it
  from `main()` or from inside a `group(...)` callback, never from inside a
  `test(...)` body.
* It takes a non-nullable `TsClient`. When the implementation may be
  unconfigured (missing credentials), wrap it in a `group` with
  `skip: client == null` and only call `tablestoreTest(client)` when the
  client is non-null - do not pass `client!` unguarded.
* Structure of what it declares: `group('tablestore')` containing
  `group('row')` (put/get/update/delete rows, column selection, missing table
  and missing record, long and binary values, batch read/write, simple and
  complex ranges with single and composite column conditions, local
  transactions) and `group('table')` (list, create, describe, delete). A few
  cases are `skip: true` in the suite itself (`no_batch`, two composite
  condition variants, `transaction2`); that is expected, do not "fix" them in
  the consumer.
* The suite creates and reuses real tables in the target instance or
  database: `test_key_string` (one string key `key`), `test_work` (four keys
  `key1` string, `key2` integer, `key3` string, `key4` integer), `test_create`
  and `test_create1` (two integer keys `gid`, `uid`), it deletes
  `test_dummy_to_delete`, and `createTableAlways` deletes every existing
  `create_table_*` table then creates the next `create_table_<n>`. Table
  creation is rate limited on the real Aliyun service, so run the full suite
  against a real instance sparingly and against a mock in CI.
* Creation is cached in top level flags for the lifetime of the process, so
  running the suite twice in one `main()` (two implementations) only creates
  each table once - which also means the second implementation may not see
  the creation calls. Prefer one test file per implementation.
* What an implementation must support to pass: `listTableNames`,
  `createTable`, `describeTable` (with `tableMeta!.toMap()` returning
  `{'name': ..., 'primaryKeys': [{'name': ..., 'type': 'string'|'integer'}]}`
  and `toMap()` returning `tableMeta`/`reservedThroughput`/`tableOptions`),
  `deleteTable`, the whole row API including `batchGetRows`,
  `batchWriteRows`, `getRange` with `TsValueInfinite` bounds and column
  conditions, `startLocalTransaction`, plus `TsValueLong` and `Uint8List`
  values.
* The suite is platform agnostic (no `dart:io`, no `dart:js`); the package's
  `dart_test.yaml` declares `platforms: [ vm, node ]`. Run it with
  `dart test` on the VM, or through `tekartik_build_node` for the node
  compiled variant.
* For the ready made universal wiring (memory on the VM, real service on
  node), use `tekartik_aliyun_tablestore_universal_test` rather than wiring
  `tablestoreTest` yourself.

## Examples

### Run the suite against a mock implementation

```dart
// dev_dependencies: tekartik_aliyun_tablestore_sembast
// (git url: https://github.com/tekartik/aliyun.dart, path: common/tablestore_sembast)
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';
import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';
import 'package:test/test.dart';

void main() {
  group('sembast_memory', () {
    // A fresh in memory database, nothing is persisted.
    tablestoreTest(newTablestoreSembastMemory().client());
  });
}
```

### Run it against a real client, skipped when not configured

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';
import 'package:test/test.dart';

/// [tablestore] is an implementation (`tablestoreNode`,
/// `tablestoreUniversal`...), [options] comes from the environment and is
/// null when the credentials are missing.
void defineTests(Tablestore tablestore, TsClientOptions? options) {
  var client = options == null ? null : tablestore.client(options: options);
  group('my_implementation', () {
    if (client != null) {
      tablestoreTest(client);
    }
  }, skip: client == null);
}
```

### A reusable entry point for your own implementation package

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart'
    as tablestore_test;
import 'package:test/test.dart';

/// Expose this from your own `*_test` helper package so consumers only
/// need one call. Declares nothing when [client] is null.
void runTablestoreTests(TsClient? client, {String name = 'tablestore'}) {
  group(name, () {
    if (client != null) {
      tablestore_test.tablestoreTest(client);
    }
  }, skip: client == null);
}
```

### Clean up the tables the suite leaves behind

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

/// Optional maintenance: the suite reuses these tables, only drop them when
/// the schema changed. Table creation is rate limited on the real service.
Future<void> dropSuiteTables(TsClient client) async {
  var names = await client.listTableNames();
  for (var name in names) {
    if (const [
          'test_key_string',
          'test_work',
          'test_create',
          'test_create1',
          'test_dummy_to_delete',
        ].contains(name) ||
        name.startsWith('create_table_')) {
      try {
        await client.deleteTable(name);
      } on TsException catch (e) {
        if (!e.isTableNotExistError) {
          rethrow;
        }
      }
    }
  }
}
```

## Common mistakes

* Adding the package to `dependencies` instead of `dev_dependencies`.
* Calling `tablestoreTest` inside a `test(...)` body: it declares groups and
  must run at collection time.
* Passing `client!` when the credentials are missing instead of skipping the
  group.
* Running the full suite against a production instance: it creates, deletes
  and rewrites fixed table names.
* Importing `package:tekartik_aliyun_tablestore_test/src/...` to reuse
  `createWorkTable` or `getWorkTableKey`: they are not exported.
