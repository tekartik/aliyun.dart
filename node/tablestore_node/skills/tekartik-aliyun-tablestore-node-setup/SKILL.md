---
name: tekartik-aliyun-tablestore-node-setup
description: >-
  Use when Dart code compiled to javascript with dart2js and run by nodejs must
  reach the real Aliyun Tablestore (OTS) service with
  tekartik_aliyun_tablestore_node: tablestoreNode, its
  client(options: TsClientOptions(endpoint, accessKeyId, secretAccessKey,
  instanceName)), the package:tekartik_aliyun_tablestore_node/tablestore_node.dart
  and environment_client.dart imports (tsClientOptionsFromEnv,
  getTsClientOptionsFromEnv), the endpoint / accessKeyId / secretAccessKey /
  instanceName environment variables, the tablestore npm module, the
  TablestoreNode constants (primaryKeyType, rowExistenceExpectation,
  returnType, comparatorType, logicalOperator, direction), its automatic retry
  of retryable TsException, and the dart2js node build and @TestOn('node')
  tests.
---

# Tablestore on nodejs (tekartik_aliyun_tablestore_node)

`tekartik_aliyun_tablestore_node` implements the
`tekartik_aliyun_tablestore` API over the `tablestore` npm module. It is
javascript only: the library imports `dart:js`, so it compiles for dart2js
(nodejs, typically an Aliyun Function Compute function) and for no other
platform. Shared code that must also run on the Dart VM should depend on
`tekartik_aliyun_tablestore_universal` instead.

## Guidelines

* Dependency (git, not published on pub.dev), plus the node tool chain of the
  [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build):
  ```yaml
  dependencies:
    tekartik_aliyun_tablestore:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/tablestore
      version: '>=0.2.3'
    tekartik_aliyun_tablestore_node:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: node/tablestore_node
      version: '>=0.2.5'
  dev_dependencies:
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.4.19'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
  ```
  And the node module: `"tablestore": "^5.0.7"` in `package.json`, then
  `npm install`. `node_modules` must be deployed next to the generated
  `index.js`.
* Unlike the other tekartik node packages, `tablestore_node.dart` exports
  **only** `tablestoreNode`; it does not re-export the API. Import both
  `package:tekartik_aliyun_tablestore/tablestore.dart` (for `TsClient`,
  `TsClientOptions`, `TsPrimaryKey`, `TsAttributes`, `TsException`...) and
  `package:tekartik_aliyun_tablestore_node/tablestore_node.dart`, and declare
  `tekartik_aliyun_tablestore` explicitly in `pubspec.yaml`.
* Never import `package:tekartik_aliyun_tablestore_node/src/...`: the interop,
  shim and conversion helpers (`tablestoreJs`, `TsExceptionNode`, `debugTs`,
  `toPutRowParams`...) are private to the package and change without notice.
* Get the client with
  `tablestoreNode.client(options: TsClientOptions(endpoint: , accessKeyId: , secretAccessKey: , instanceName: ))`.
  `options` is **mandatory** here: `client()` without it crashes (null check).
  `endpoint` is the instance endpoint
  (`https://<instance>.<region>.ots.aliyuncs.com`) and `instanceName` the
  Tablestore instance name; both are required by the real service even though
  `instanceName` is optional in the shared `TsClientOptions`.
* Once the `TsClient` is built, code against the shared API only
  (`putRow`, `getRow`, `updateRow`, `deleteRow`, `getRange`, `batchGetRows`,
  `batchWriteRows`, `startLocalTransaction`, `listTableNames`, `createTable`,
  `describeTable`, `deleteTable`). See the `tekartik-aliyun-tablestore-tables`
  and `tekartik-aliyun-tablestore-rows` skills for that API.
* Node specific behaviours to expect:
  * Every native call is retried up to 3 times (immediately, then after 1s).
    A `TsException` whose `retryable` is false is rethrown at once; when the
    retries run out the call fails with a `TsException` whose `message` is
    `timeout`. Do not add your own retry loop on top.
  * `createTable` resolves to `null` and prints the native response; read the
    schema back with `describeTable` if you need it.
  * `deleteTable` returns the deleted `TsTableDescription?`.
  * Errors raised by the `tablestore` npm module are translated to
    `TsException`; test `isTableNotExistError`, `isConditionFailedError`,
    `isPrimaryKeySizeError`, `isPrimaryKeyTypeError` and `retryable` instead
    of parsing `message`.
* Credentials: read them from the environment with
  `package:tekartik_aliyun_tablestore_node/environment_client.dart` -
  `tsClientOptionsFromEnv` (the `endpoint`, `accessKeyId`, `secretAccessKey`
  and `instanceName` variables) or `getTsClientOptionsFromEnv(env)` on any
  map, which returns `null` plus a printed message when one is missing.
  Never hard code them, never commit them.
* Caveat on `tsClientOptionsFromEnv`: it only reads the environment when
  running as javascript. On the Dart VM it returns a **dummy**
  `TsClientOptions(endpoint: 'local', accessKeyId: '', secretAccessKey: '')`
  for the io simulator, so a `!= null` check does not tell you the node
  credentials are set. Use `getTsClientOptionsFromEnv(...)` when you need a
  strict check, and mark the tests `@TestOn('node')`.
* `tablestoreNode` also exposes the raw npm constants, handy when comparing
  with the javascript documentation: `primaryKeyType` (`INTEGER` 1, `STRING`
  2, `BINARY` 3), `rowExistenceExpectation` (`IGNORE`, `EXPECT_EXIST`,
  `EXPECT_NOT_EXIST`), `returnType` (`NONE`, `Primarykey`, `AfterModify`),
  `comparatorType`, `logicalOperator`, `direction` (`FORWARD` / `BACKWARD`)
  and `long`. Prefer the portable enums of the shared API
  (`TsColumnType`, `TsCondition`, `TsDirection`) in real code.
* Tests: `dart_test.yaml` declares `platforms: [ vm, node ]`. Pure conversion
  tests run on the vm, anything touching `tablestoreNode` must be
  `@TestOn('node')` and skipped when the options are missing. Run them with
  `nodeRunTest()` from `package:tekartik_build_node/build_node.dart` (needs
  `npm install` and the `build.yaml` dart2js entrypoint config). The shared
  suite lives in `tekartik_aliyun_tablestore_test`
  (`tablestoreTest(client)`), wired for node by
  `tekartik_aliyun_tablestore_universal_test`.

## Examples

### Client from the environment, list the tables

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_node/tablestore_node.dart';

Future<void> main() async {
  // endpoint, accessKeyId, secretAccessKey and instanceName env variables.
  var options = tsClientOptionsFromEnv;
  if (options == null) {
    return;
  }
  var client = tablestoreNode.client(options: options);
  for (var name in await client.listTableNames()) {
    print(name);
  }
}
```

### Explicit options (never hard code the secret)

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/tablestore_node.dart';

/// Read the values from the function environment or a secret manager,
/// never from a literal in the source.
TsClient openClient({
  required String endpoint,
  required String instanceName,
  required String accessKeyId,
  required String secretAccessKey,
}) {
  return tablestoreNode.client(
    options: TsClientOptions(
      endpoint: endpoint,
      instanceName: instanceName,
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
    ),
  );
}
```

### Write and read back a row on node

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_node/tablestore_node.dart';

Future<void> main() async {
  var options = getTsClientOptionsFromEnv(const {});
  if (options == null) {
    return;
  }
  var client = tablestoreNode.client(options: options);
  var primaryKey = TsPrimaryKey([TsKeyValue.string('key', 'my_key')]);
  await client.putRow(
    TsPutRowRequest(
      tableName: 'test',
      primaryKey: primaryKey,
      data: TsAttributes([TsAttribute.string('text', 'hello')]),
      condition: TsCondition.ignore,
    ),
  );
  var response = await client.getRow(
    TsGetRowRequest(tableName: 'test', primaryKey: primaryKey),
  );
  var row = response.row;
  if (row.exists) {
    print(row.attributes?.toMap());
  }
}
```

### Create a table, tolerating an already existing one

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

/// [client] comes from `tablestoreNode.client(options: ...)`.
/// On node createTable resolves to null: read the schema back instead.
Future<TsTableDescription> ensureTable(
  TsClient client,
  String tableName,
) async {
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
  return client.describeTable(tableName);
}
```

### Node only test, skipped without configuration

```dart
@TestOn('node')
library;

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_node/tablestore_node.dart';
import 'package:test/test.dart';

TsClient? get tsClientTest => tsClientOptionsFromEnv != null
    ? tablestoreNode.client(options: tsClientOptionsFromEnv)
    : null;

void main() {
  var client = tsClientTest;
  group('tablestore_node', () {
    test('primaryKeyType', () {
      expect(tablestoreNode.primaryKeyType.INTEGER, 1);
      expect(tablestoreNode.primaryKeyType.STRING, 2);
      expect(tablestoreNode.primaryKeyType.BINARY, 3);
    });
    test('listTableNames', () async {
      expect(await client!.listTableNames(), isNotEmpty);
    });
  }, skip: client == null);
}
```

### build.yaml and running the node tests

```yaml
targets:
  $default:
    sources:
      - "$package$"
      - "lib/**"
      - "bin/**"
      - "test/**"
    builders:
      build_web_compilers|entrypoint:
        generate_for:
          - bin/**
        options:
          compiler: dart2js
```

```dart
import 'package:tekartik_build_node/build_node.dart';

Future<void> main() async {
  // tool/run_test_node.dart: dart2js then node (needs npm install tablestore).
  await nodeRunTest();
}
```

## Common mistakes

* Importing `tablestore_node.dart` from code that must also run on the Dart
  VM or the browser: it pulls `dart:js` and will not compile. Use
  `tekartik_aliyun_tablestore_universal`.
* Calling `tablestoreNode.client()` without `options`.
* Expecting `tsClientOptionsFromEnv` to be `null` on the VM when nothing is
  configured: it returns a local placeholder there.
* Forgetting `npm install` / shipping the function without `node_modules`:
  the `tablestore` module is resolved at runtime.
* Re-implementing retries, or treating the `timeout` `TsException` as a
  transport bug: it means the 3 internal retries all failed.
