# tekartik_aliyun_tablestore_node

The `tekartik_aliyun_tablestore` API (Aliyun Tablestore / OTS: tables, rows,
conditions, ranges, batches) on Node.js, over the `tablestore` npm module.
For Dart compiled to JavaScript (dart2js) and run by node, typically in an
Aliyun Function Compute function (`tekartik_aliyun_fc_node`).

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_aliyun_tablestore:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/tablestore
  tekartik_aliyun_tablestore_node:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: node/tablestore_node
```

And the npm module next to `pubspec.yaml` (deployed with the compiled js):

```bash
npm install tablestore
```

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_node/tablestore_node.dart';

Future<void> main() async {
  // endpoint, accessKeyId, secretAccessKey and instanceName environment
  // variables; never hard code the secret.
  var options = tsClientOptionsFromEnv;
  if (options == null) {
    return;
  }
  var client = tablestoreNode.client(options: options);
  var primaryKey = TsPrimaryKey([TsKeyValue.string('key', 'my_key')]);
  await client.putRow(
    TsPutRowRequest(
      tableName: 'test',
      primaryKey: primaryKey,
      data: TsAttributes([
        TsAttribute.string('text', 'hello'),
        TsAttribute.int('count', 1),
        TsAttribute.double('ratio', 0.5),
      ]),
    ),
  );
  var response = await client.getRow(
    TsGetRowRequest(tableName: 'test', primaryKey: primaryKey),
  );
  print(response.row.attributes?.toMap());
}
```

`tablestore_node.dart` exports `tablestoreNode` only: import the API from
`tekartik_aliyun_tablestore` too.

## Platforms

Node.js only: the library imports `dart:js` and does not compile for the VM
or the browser. Code that must also run on the Dart VM uses
`tekartik_aliyun_tablestore_universal` (the `tablestore` module on node, a
sembast database on the VM).

## Errors

Errors are `TsException`s: test `isTableNotExistError`,
`isConditionFailedError` (an `OTSConditionCheckFail`, not any 403: an
authentication or permission error is not a condition failure),
`isPrimaryKeySizeError`, `isPrimaryKeyTypeError` and `retryable`. A
retryable error is tried 3 times (immediately, then after 1 s); when they all
fail the call throws a `TsException` whose message is `timeout`.

## Common pitfalls

* `client()` needs `options`, with the instance `endpoint` and the
  `instanceName`.
* Integers are `TsValueLong` (`TsKeyValue.int`, `TsAttribute.int`,
  `TsValueLong.fromNumber`). A plain Dart number is sent as a JavaScript
  number, stored as DOUBLE: dart2js cannot tell `1` from `1.0`, so
  `TsAttribute('count', 1)` is a DOUBLE column. Condition values follow the
  same rule (`TsColumnCondition.greaterThan('ratio', 0.5)` compares a
  DOUBLE).
* `createTable` prints the native response and returns null: read the
  schema back with `describeTable`.
* `tsClientOptionsFromEnv` is a local placeholder on the Dart VM (for the
  sembast simulation), never null there.
* Tests: `npm install` (`package.json`), then `dart test -p node`. The tests
  reaching a real instance are skipped without the environment variables.
