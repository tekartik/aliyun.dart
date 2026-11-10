# tekartik_aliyun_oss_node

The `tekartik_aliyun_oss` API (Aliyun Object Storage Service: buckets,
objects, listing) on Node.js, over the `ali-oss` npm module. For Dart
compiled to JavaScript (dart2js) and run by node, typically in an Aliyun
Function Compute function (`tekartik_aliyun_fc_node`).

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_aliyun_oss_node:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: node/oss_node
```

And the npm module next to `pubspec.yaml` (deployed with the compiled js):

```bash
npm install ali-oss
```

```dart
import 'package:tekartik_aliyun_oss_node/oss_node.dart';

/// [bucketName] must exist (create it in the Aliyun console).
Future<void> ossDemo(OssClientOptions options, String bucketName) async {
  var client = ossServiceNode.client(options: options);
  await client.putAsString(bucketName, 'demo/hello.txt', 'hello');
  print(await client.getAsString(bucketName, 'demo/hello.txt'));
  var response = await client.list(
    bucketName,
    OssListFilesOptions(prefix: 'demo/'),
  );
  print(response.files.map((file) => file.name));
  await client.delete(bucketName, 'demo/hello.txt');
}

Future<void> main() async {
  // Read the credentials from the environment, never from the source.
  await ossDemo(
    OssClientOptions(
      endpoint: 'oss-eu-central-1.aliyuncs.com',
      accessKeyId: '<access key id>',
      accessKeySecret: '<access key secret>',
    ),
    'my-bucket',
  );
}
```

`package:tekartik_aliyun_oss_node/environment_client.dart` builds the
options from the `endpoint`, `accessKeyId` and `accessKeySecret` environment
variables (`ossNodeClientOptionsFromEnv`, null when one is missing).

## Platforms

Node.js only (dart2js): elsewhere `ossServiceNode` throws
`UnimplementedError`. Code that must also run on the Dart VM uses
`tekartik_aliyun_oss_universal` (ali-oss on node, a file system mock on the
VM).

## Errors

Every error is an `OssException`: `isNotFound` for a 404 (missing bucket or
object), `retryable` false for a client error (4xx: access denied, bad
request...). The client tries 3 times (immediately, then after 1 s) on the
other errors (5xx, network) and throws the last one.

## Common pitfalls

* `client()` needs `options`. `endpoint` is the region endpoint, not the
  bucket url. `OssClientOptions.toString()` hides the secrets.
* `getAsBytes`/`getAsString` of a missing object throws (`isNotFound`), it
  does not return null. `delete` of a missing object succeeds.
* `putBucket` is not implemented on node: create buckets in the console.
* Listing is paginated: continue with `marker: response.nextMarker` only
  while `response.isTruncated` is true.
* One client switches bucket internally (`useBucket`), so its calls run one
  at a time.
* Tests: `npm install` (`package.json`), then `dart test -p node`. The tests
  reaching a real bucket are skipped without the environment variables.
