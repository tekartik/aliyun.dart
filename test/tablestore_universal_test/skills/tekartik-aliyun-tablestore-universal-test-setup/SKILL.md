---
name: tekartik-aliyun-tablestore-universal-test-setup
description: >-
  Use when running the shared Aliyun Tablestore conformance suite on both the
  Dart VM (sembast memory mock) and nodejs (real OTS service) with
  tekartik_aliyun_tablestore_universal_test: the tsClientTest getter and the
  tablestoreTest(TsClient? client) wrapper from
  package:tekartik_aliyun_tablestore_universal_test/tablestore_test.dart, its
  group('universal') and skip-when-null behaviour, wiring
  tablestoreUniversal / newTablestoreMemory and tsClientOptionsFromEnv, the
  endpoint / accessKeyId / secretAccessKey / instanceName environment
  variables, dart test -p vm and nodePackageRunTest for the dart2js node run.
---

# Universal Tablestore test wiring (tekartik_aliyun_tablestore_universal_test)

`tekartik_aliyun_tablestore_universal_test` is the glue that runs the shared
`tekartik_aliyun_tablestore_test` suite through
`tekartik_aliyun_tablestore_universal`: on the Dart VM against the in memory
sembast mock, compiled with dart2js and run by nodejs against the real Aliyun
Tablestore service.

## Guidelines

* Dev dependency (git, not published on pub.dev). It pulls
  `tekartik_aliyun_tablestore_universal`,
  `tekartik_aliyun_tablestore_node` and `tekartik_aliyun_tablestore_test`:
  ```yaml
  dev_dependencies:
    tekartik_aliyun_tablestore_universal_test:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: test/tablestore_universal_test
    test: '>=1.31.0'
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.4.19'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
  ```
  For the node run also add a `package.json` with `"tablestore": "^5.0.7"`
  and run `npm install`.
* One public library,
  `package:tekartik_aliyun_tablestore_universal_test/tablestore_test.dart`,
  with three symbols:
  * `TsClient? get tsClientTest` -
    `tablestoreUniversal.client(options: tsClientOptionsFromEnv)`, or `null`
    when `tsClientOptionsFromEnv` is null.
  * `void tablestoreTest(TsClient? client)` - wraps the shared suite in
    `group('universal')` and sets `skip: client == null`. Note the
    **nullable** parameter: this is not the `tablestoreTest(TsClient)` of
    `tekartik_aliyun_tablestore_test`, which it calls internally. When you
    need both in one file, import the shared one with a prefix.
  * `void main()` - `tablestoreTest(tsClientTest)`, the default entry point.
* A test file is just `void main() { tablestoreTest(tsClientTest); }`. Use
  `tablestoreTest(newTablestoreMemory().client())` (from
  `tekartik_aliyun_tablestore_universal`) for a deterministic run that never
  needs credentials.
* What `tsClientTest` actually targets depends on the platform, because
  `tsClientOptionsFromEnv` behaves differently:
  * On the **VM** it never reads the environment: it returns a placeholder
    `TsClientOptions(endpoint: 'local', ...)`, so `tsClientTest` is non null
    and the suite runs against the **in memory sembast mock**. Nothing is
    persisted and no credential is needed.
  * On **node** it reads the `endpoint`, `accessKeyId`, `secretAccessKey` and
    `instanceName` environment variables and returns `null` (printing which
    one is missing) when one is absent, so the suite is skipped instead of
    failing.
* Credentials for the node run come from the environment. In this repo they
  are kept in a `process_run` user config (`.local/ds_env.example.yaml` shows
  the shape: `var: accessKeyId, secretAccessKey, endpoint, instanceName`) and
  read with `userEnvironment` from `package:process_run/shell.dart`. Never
  commit real keys, never inline them in a test.
* Running:
  * VM: `dart test -p vm` (`tool/run_universal_test_io.dart`).
  * node: `nodePackageRunTest('.')` from
    `package:tekartik_build_node/build_node.dart`
    (`tool/run_universal_test_node.dart`) - it compiles with dart2js and runs
    node, so `npm install` must have been done first.
  * CI: `ioPackageRunCi('.')` from `package:dev_build/package.dart`.
  * `dart_test.yaml` declares `platforms: [ vm, node ]`.
* The suite creates and reuses fixed tables (`test_key_string`, `test_work`,
  `test_create`, `test_create1`, rotating `create_table_<n>`) in the target
  instance; see the `tekartik-aliyun-tablestore-test-suite` skill. Table
  creation is rate limited on the real service: point the node run at a
  dedicated test instance, not at production.
* For a plain unit test of your own code, prefer
  `newTablestoreMemory().client()` directly and keep this package for
  conformance runs.

## Examples

### Default entry point (memory on the VM, real service on node)

```dart
import 'package:tekartik_aliyun_tablestore_universal_test/tablestore_test.dart';

void main() {
  // Skipped on node when endpoint/accessKeyId/secretAccessKey/instanceName
  // are not set; runs against the sembast memory mock on the VM.
  tablestoreTest(tsClientTest);
}
```

### Deterministic memory run, no credentials needed

```dart
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:tekartik_aliyun_tablestore_universal_test/tablestore_test.dart';
import 'package:test/test.dart';

void main() {
  group('tablestoreMemory', () {
    tablestoreTest(newTablestoreMemory().client());
  });
}
```

### Both wrappers in one file, with a prefix

```dart
import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart'
    as shared;
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:tekartik_aliyun_tablestore_universal_test/tablestore_test.dart';

void main() {
  // Nullable wrapper: adds group('universal') and skips when null.
  tablestoreTest(tsClientTest);

  // Non nullable shared suite (TsClient), on an explicit memory client.
  var memoryClient = newTablestoreMemory().client();
  shared.tablestoreTest(memoryClient);
}
```

### Check the configured options before running on node

```dart
@TestOn('vm')
library;

import 'package:process_run/shell.dart';
import 'package:tekartik_aliyun_tablestore_node/environment_client.dart';
import 'package:test/test.dart';

void main() {
  // Reads the process_run user environment (never hard code the secret).
  var options = getTsClientOptionsFromEnv(userEnvironment);
  test('options', () {
    expect(options!.endpoint, isNotEmpty);
    expect(options.instanceName, isNotNull);
  }, skip: options == null);
}
```

### Tool scripts to run both platforms

```dart
import 'package:tekartik_build_node/build_node.dart';

Future<void> main() async {
  // tool/run_universal_test_node.dart: dart2js then node.
  // Needs `npm install` (tablestore module) in the package directory.
  await nodePackageRunTest('.');
}
```

## Common mistakes

* Expecting the VM run to hit the real service: on the VM
  `tsClientOptionsFromEnv` is a local placeholder and the suite runs on the
  sembast memory mock.
* Passing a non-null `TsClient` to the shared `tablestoreTest` and this
  package's `tablestoreTest` interchangeably: the signatures differ
  (`TsClient` vs `TsClient?`), import one with a prefix.
* Running the node variant without `npm install`: the `tablestore` module is
  resolved at runtime.
* Pointing the node run at a production instance: the suite deletes and
  recreates tables.
