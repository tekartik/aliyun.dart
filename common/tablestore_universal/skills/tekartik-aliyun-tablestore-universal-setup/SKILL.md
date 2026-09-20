---
name: tekartik-aliyun-tablestore-universal-setup
description: >-
  Use when the same Dart code must reach Aliyun Tablestore on the nodejs
  runtime and a local sembast database on the Dart VM with
  tekartik_aliyun_tablestore_universal: tablestoreUniversal (tablestoreNode on
  node, tablestoreSembastMemory on io), getTablestore(localRootPath,
  localInMemory), newTablestoreMemory, the re-exported
  tekartik_aliyun_tablestore API (Tablestore, TsClient, TsClientOptions,
  TsPrimaryKey, TsAttributes...), the package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart
  and environment_client.dart imports (tsClientOptionsFromEnv,
  getTsClientOptionsFromEnv), the endpoint / accessKeyId / secretAccessKey /
  instanceName environment variables, the tablestore npm dependency and
  running the tests on vm and node.
---

# Universal Tablestore (tekartik_aliyun_tablestore_universal)

`tekartik_aliyun_tablestore_universal` exposes one `tablestoreUniversal`
implementing the `tekartik_aliyun_tablestore` API. Compiled to javascript and
run by nodejs (typically an Aliyun Function Compute function) it is
`tablestoreNode`, the real service over the `tablestore` npm module; on the
Dart VM it is the `tekartik_aliyun_tablestore_sembast` mock. It also
re-exports the whole Tablestore API, so a single import is enough.

## Guidelines

* Dependency (git, not published on pub.dev), plus the node tool chain of the
  [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build):
  ```yaml
  dependencies:
    tekartik_aliyun_tablestore_universal:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/tablestore_universal
      version: '>=0.2.3'
  dev_dependencies:
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.4.19'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
  ```
  For the node side add a `package.json` with `"tablestore": "^5.0.7"` and run
  `npm install`.
* Import `package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart`:
  it re-exports every `tekartik_aliyun_tablestore` type (`Tablestore`,
  `TsClient`, `TsClientOptions`, `TsPrimaryKey`, `TsKeyValue`, `TsAttribute`,
  `TsAttributes`, `TsPutRowRequest`, `TsGetRangeRequest`, `TsException`...)
  plus `tablestoreUniversal`, `getTablestore` and `newTablestoreMemory`.
  Do not add a direct import of `tekartik_aliyun_tablestore_node` or
  `tekartik_aliyun_tablestore_sembast` in shared code - that breaks the
  platform that cannot compile it. `tablestore` (the bare getter) is
  deprecated, use `tablestoreUniversal`.
* Pick the instance:
  * `tablestoreUniversal` - node: the real service; VM: the **in memory**
    sembast mock (nothing is persisted between runs).
  * `getTablestore(localRootPath: 'path', localInMemory: false)` - node:
    identical to `tablestoreUniversal`, both arguments ignored; VM: a file
    backed sembast database under `localRootPath` (keep it out of the way,
    e.g. `.dart_tool/tablestore` or `.local`), or the memory one when
    `localInMemory` is true. Use it for a dev/offline mode that must keep its
    data.
  * `newTablestoreMemory()` - always a fresh, isolated sembast memory
    instance, on every platform. This is what unit tests should use.
* Then `tablestore.client(options: TsClientOptions(endpoint:, accessKeyId:, secretAccessKey:, instanceName:))`.
  On node all four matter (`instanceName` is the Tablestore instance); on the
  mock credentials are ignored and `instanceName` becomes the sembast
  database path. `client()` without options is valid on the mock only.
* `package:tekartik_aliyun_tablestore_universal/environment_client.dart` is a
  public helper: `tsClientOptionsFromEnv` reads `endpoint`, `accessKeyId`,
  `secretAccessKey` and `instanceName` from the environment on node
  (returning `null` plus a printed message when one is missing) and returns
  dummy local options on the VM; `getTsClientOptionsFromEnv(env)` does the
  same on any map (pass `userEnvironment` from `package:process_run/shell.dart`
  to read the user config on the VM). Build the test/tool client as
  `tsClientOptionsFromEnv != null ? tablestoreUniversal.client(options: tsClientOptionsFromEnv) : null`
  and `skip:` the group when it is null.
* Never commit the credentials: on the VM they come from the `process_run`
  user config (`.local/ds_env.yaml`, `var:` section), on node from the
  function's environment variables.
* Behaviour differences to code for: `startLocalTransaction` is unimplemented
  on the mock, a `not` composite column condition is unsupported there, and
  the real service rate limits `createTable` - create tables once, guarded by
  `listTableNames()`.
* Tests: `dart_test.yaml` declares `platforms: [vm, node]`. `dart test -p vm`
  runs against the mock; `nodePackageRunTest('.')` from
  `package:tekartik_build_node/build_node.dart` compiles the tests with
  dart2js and runs them on node against the real service (needs
  `npm install`). The shared suite lives in
  `tekartik_aliyun_tablestore_test` (`tablestoreTest(TsClient client)`, git
  path `test/tablestore_test`).

## Examples

### Shared code on the universal instance

```dart
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

/// Real Tablestore on node, sembast mock on the VM.
Future<void> writeAndRead(TsClient client, String tableName) async {
  var key = TsPrimaryKey([TsKeyValue.string('key', 'universal')]);
  await client.putRow(
    TsPutRowRequest(
      tableName: tableName,
      primaryKey: key,
      data: TsAttributes([TsAttribute.int('count', 1)]),
    ),
  );
  var response = await client.getRow(
    TsGetRowRequest(tableName: tableName, primaryKey: key),
  );
  if (response.row.exists) {
    print(response.toDebugMap());
  }
}
```

### Client from the environment

```dart
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

/// node: needs the endpoint, accessKeyId, secretAccessKey and instanceName
/// environment variables; VM: always returns a mock client.
TsClient? get tsClientTest => tsClientOptionsFromEnv != null
    ? tablestoreUniversal.client(options: tsClientOptionsFromEnv)
    : null;

Future<void> main() async {
  var client = tsClientTest;
  if (client == null) {
    print('missing tablestore configuration');
    return;
  }
  print(await client.listTableNames());
}
```

### Persistent local database in a dev tool

```dart
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

Future<void> main() async {
  // VM: sembast files under .dart_tool/tablestore; node: the real service.
  var tablestore = getTablestore(localRootPath: '.dart_tool/tablestore');
  var client = tablestore.client(
    options: TsClientOptions(
      endpoint: 'local',
      accessKeyId: '',
      secretAccessKey: '',
      instanceName: 'dev.db',
    ),
  );
  var tableName = 'test_key_string';
  if (!(await client.listTableNames()).contains(tableName)) {
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
  }
}
```

### Unit test on a fresh memory instance (vm and node)

```dart
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:test/test.dart';

void main() {
  test('memory', () async {
    // Isolated, works on every platform, no configuration.
    var client = newTablestoreMemory().client();
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
      ),
    );
    expect(await client.listTableNames(), contains(tableName));
  });
}
```

### Shared suite against the configured client

```dart
import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart'
    as tablestore_test;
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:test/test.dart';

// tekartik_aliyun_tablestore_test is a dev_dependency
// (git url: https://github.com/tekartik/aliyun.dart, path: test/tablestore_test)
void main() {
  var client = tsClientOptionsFromEnv != null
      ? tablestoreUniversal.client(options: tsClientOptionsFromEnv)
      : null;
  group('universal', () {
    if (client != null) {
      tablestore_test.tablestoreTest(client);
    }
  }, skip: client == null);
}
```

### tool/run_test_node.dart

```dart
import 'package:tekartik_build_node/build_node.dart';

Future<void> main() async {
  // dart2js compile of the tests, then run with node (needs npm install).
  await nodePackageRunTest('.');
}
```
