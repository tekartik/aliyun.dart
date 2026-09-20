---
name: tekartik-aliyun-oss-node-setup
description: >-
  Use when Dart code compiled to javascript and run by nodejs must reach Aliyun
  Object Storage Service with tekartik_aliyun_oss_node: ossServiceNode, its
  client(options: OssClientOptions(endpoint, accessKeyId, accessKeySecret)),
  the re-exported tekartik_aliyun_oss API (OssClient, OssBucket, OssFile,
  OssListFilesOptions, OssListFilesResponse, OssException, debugAliyunOss) with
  listBuckets, getBucket, putAsString, putAsBytes, getAsString, getAsBytes,
  delete and list, the package:tekartik_aliyun_oss_node/oss_node.dart and
  environment_client.dart imports (ossNodeClientOptionsFromEnv,
  getOssNodeClientOptionsFromEnv), the ali-oss npm module and the dart2js node
  build and tests.
---

# OSS on nodejs (tekartik_aliyun_oss_node)

`tekartik_aliyun_oss_node` implements the `tekartik_aliyun_oss` API over the
`ali-oss` npm module. It only works in javascript compiled with dart2js and
run by nodejs (typically an Aliyun Function Compute function); on any other
platform `ossServiceNode` throws `UnimplementedError`.

## Guidelines

* Prefer `tekartik_aliyun_oss_universal` when the same code must also run on
  the Dart VM: it picks `ossServiceNode` on node and the file system mock
  elsewhere. Depend on `tekartik_aliyun_oss_node` directly only for node-only
  code or to write the node half of a universal package.
* Dependency (git, not published on pub.dev), plus the node tool chain of the
  [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build):
  ```yaml
  dependencies:
    tekartik_aliyun_oss_node:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: node/oss_node
      version: '>=0.3.0'
  dev_dependencies:
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.4.19'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
  ```
  And the node module: `npm install ali-oss --save`
  (`"ali-oss": "^6.11.2"` in `package.json`). It must be deployed next to
  `index.js`.
* `package:tekartik_aliyun_oss_node/oss_node.dart` re-exports the whole
  `tekartik_aliyun_oss` API (`OssService`, `OssClient`, `OssClientOptions`,
  `OssBucket`, `OssFile`, `OssListFilesOptions`, `OssListFilesResponse`,
  `OssException`, `debugAliyunOss`) and adds `ossServiceNode`, so one import
  is enough.
* `ossServiceNode.client(options: OssClientOptions(endpoint: , accessKeyId: , accessKeySecret: ))`.
  `options` is **mandatory** here: `client()` without it crashes (null check).
  The endpoint is the region endpoint (`oss-eu-central-1.aliyuncs.com`), not
  the bucket url. `OssClientOptions.toString()` obfuscates the secrets, so it
  is safe to log.
* Client operations, all bucket name first:
  `listBuckets()`, `getBucket(name)`, `putAsString(bucket, path, text)`,
  `putAsBytes(bucket, path, Uint8List)`, `getAsString(bucket, path)`,
  `getAsBytes(bucket, path)`, `delete(bucket, path)` (ignores a missing
  object) and `list(bucket, OssListFilesOptions(prefix:, maxResults:, marker:))`.
* `putBucket(name)` is **not** implemented on node (it throws
  `UnimplementedError`, it only exists for the mocks): create the bucket in
  the Aliyun console first.
* A missing object throws an `OssException` with `isNotFound` true (the
  ali-oss `NoSuchKeyError` is translated); use `retryable` to decide whether
  to retry. Catch it rather than expecting a null.
* Listing is paginated: read `response.files` (`OssFile` with `name`, `size`,
  `lastModified`), and only continue while `response.isTruncated` is true,
  reusing `response.nextMarker` as the `marker` of the next
  `OssListFilesOptions` (`nextMarker` can be non null even when the listing is
  over, so test `isTruncated` first).
* The underlying ali-oss client is stateful (it switches bucket with
  `useBucket`), so every call is serialized behind an internal lock: do not
  expect parallelism from `Future.wait` on this client, and do not share one
  client across unrelated concurrent flows when latency matters.
* Set `debugAliyunOss = true` (deprecated, dev only) to log every native
  request and response on stdout under the `/oss_node` prefix.
* Credentials: read them from the environment with
  `package:tekartik_aliyun_oss_node/environment_client.dart` -
  `ossNodeClientOptionsFromEnv` (the `endpoint`, `accessKeyId` and
  `accessKeySecret` variables, `null` plus a printed message when one is
  missing) or `getOssNodeClientOptionsFromEnv(env)` on any map. Never hard
  code them, never commit them.
* Tests: `dart_test.yaml` declares `platforms: [ vm, node ]`; mark the OSS
  tests `@TestOn('node')` and `skip:` the group when the options are null.
  Run them with `nodePackageRunTest('.')` from
  `package:tekartik_build_node/build_node.dart` (needs `npm install` and the
  `build.yaml` dart2js entrypoint config).

## Examples

### Client from the environment, list buckets

```dart
import 'package:tekartik_aliyun_oss_node/environment_client.dart';
import 'package:tekartik_aliyun_oss_node/oss_node.dart';

Future<void> main() async {
  // endpoint, accessKeyId and accessKeySecret environment variables.
  var options = ossNodeClientOptionsFromEnv;
  if (options == null) {
    return;
  }
  var client = ossServiceNode.client(options: options);
  print('options: $options'); // secrets are obfuscated
  for (var bucket in await client.listBuckets()) {
    print('${bucket.name} ${bucket.location}');
  }
}
```

### Upload, download and delete an object

```dart
import 'dart:typed_data';

import 'package:tekartik_aliyun_oss_node/oss_node.dart';

Future<void> roundTrip(OssClient client, String bucketName) async {
  await client.putAsString(bucketName, 'config/app.json', '{"version": 1}');
  await client.putAsBytes(
    bucketName,
    'img/pixel.bin',
    Uint8List.fromList([1, 2, 3]),
  );

  print(await client.getAsString(bucketName, 'config/app.json'));

  await client.delete(bucketName, 'img/pixel.bin');
  try {
    await client.getAsBytes(bucketName, 'img/pixel.bin');
  } on OssException catch (e) {
    if (!e.isNotFound) {
      rethrow;
    }
    print('deleted');
  }
}
```

### Paginated listing of a prefix

```dart
import 'package:tekartik_aliyun_oss_node/oss_node.dart';

Future<List<OssFile>> listAll(
  OssClient client,
  String bucketName,
  String prefix,
) async {
  var files = <OssFile>[];
  var options = OssListFilesOptions(prefix: prefix, maxResults: 100);
  while (true) {
    var response = await client.list(bucketName, options);
    files.addAll(response.files);
    // nextMarker can be set even when done: check isTruncated.
    if (!response.isTruncated) {
      break;
    }
    options = OssListFilesOptions(
      prefix: prefix,
      maxResults: 100,
      marker: response.nextMarker,
    );
  }
  for (var file in files) {
    print('${file.name} ${file.size} ${file.lastModified}');
  }
  return files;
}
```

### Node only test, skipped without configuration

```dart
@TestOn('node')
library;

import 'package:tekartik_aliyun_oss_node/environment_client.dart';
import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:test/test.dart';

OssClient? get ossClientTest => ossNodeClientOptionsFromEnv != null
    ? ossServiceNode.client(options: ossNodeClientOptionsFromEnv)
    : null;

void main() {
  var client = ossClientTest;
  group('oss_node', () {
    test('listBuckets', () async {
      var buckets = await client!.listBuckets();
      expect(buckets, isNotEmpty);
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
  // tool/run_test_node.dart: dart2js then node (needs npm install ali-oss).
  await nodePackageRunTest('.');
}
```
