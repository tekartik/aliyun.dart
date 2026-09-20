---
name: tekartik-aliyun-oss-universal-setup
description: >-
  Use when the same Dart code must reach Aliyun OSS on the nodejs runtime and
  use a local file system mock on the Dart VM with tekartik_aliyun_oss_universal:
  ossServiceUniversal (ossServiceNode on node, ossServiceFsIo on io),
  ossServiceMemory and newOssServiceMemory for unit tests, OssClientOptions
  from the endpoint, accessKeyId, accessKeySecret and ossTestBucketName
  environment variables, the package:tekartik_aliyun_oss_universal/oss_universal.dart
  and test/environment_client.dart imports (ossClientTest,
  ossClientOptionsFromEnv, isLocalTest), the ali-oss npm dependency and
  running the tests on vm and node.
---

# Universal OSS service (tekartik_aliyun_oss_universal)

`tekartik_aliyun_oss_universal` exposes one `ossServiceUniversal` implementing
the `tekartik_aliyun_oss` API. On node (code compiled with dart2js and run by
nodejs, typically a Function Compute function) it is `ossServiceNode`, the real
service over the `ali-oss` npm module; on the Dart VM it is `ossServiceFsIo`,
the `tekartik_aliyun_oss_fs` mock writing buckets to the local file system.
The memory mock is re-exported for unit tests.

## Guidelines

* Dependency (git, not on pub.dev), plus the node tool chain of the
  [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build):
  ```yaml
  dependencies:
    tekartik_aliyun_oss_universal:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/oss_universal
  dev_dependencies:
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.4.19'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
  ```
  For the node side add a `package.json` with `"ali-oss": "^6.11.2"` and run
  `npm install`. Add `tekartik_aliyun_oss_fs` (`path: common/oss_fs`) when
  you import `OssClientOptionsFs`.
* Import `package:tekartik_aliyun_oss_universal/oss_universal.dart`: the
  whole `tekartik_aliyun_oss` API (`OssService`, `OssClient`,
  `OssClientOptions`, `OssListFilesOptions`, `OssException`...) plus
  `ossServiceUniversal`, `ossServiceNode`, `ossServiceFsIo`,
  `ossServiceMemory`, `newOssServiceMemory` and `debugAliyunOss`.
  `ossServiceUniversal` is a getter
  (`isRunningAsJavascript ? ossServiceNode : ossServiceFsIo`);
  `ossServiceNode` throws `UnimplementedError` on the VM and
  `ossServiceFsIo` throws on node, so only touch them behind the universal
  getter or a platform check.
* `ossServiceUniversal.client(options: OssClientOptions(endpoint:, accessKeyId:, accessKeySecret:))`:
  on node `options` is mandatory (null crashes); on the VM the same call
  returns an fs client rooted in the current directory
  (`<cwd>/<bucket>/<object path>`). To keep the local files out of the way
  pass `OssClientOptionsFs()..rootPath = '.dart_tool/oss_fs_io'` (from
  `package:tekartik_aliyun_oss_fs/oss_fs.dart`) when not on node, which is
  what the package's own test helper does.
* `package:tekartik_aliyun_oss_universal/test/environment_client.dart` is a
  public helper library for tests and tools: `ossClientOptionsFromEnv`
  (node: read from the `endpoint`, `accessKeyId` and `accessKeySecret`
  environment variables, `null` plus a printed message when one is missing;
  VM: an `OssClientOptionsFs` rooted at `.dart_tool/oss_fs_io`),
  `ossClientTest` (`ossServiceUniversal.client(options:)` with those
  options, `null` when they are missing) and `isLocalTest` (`true` on the
  VM). The package tests also read `ossTestBucketName`, the bucket they
  write into (created locally with `putBucket`, must already exist on
  Aliyun).
* Environment variables for local runs come from `.local/ds_env.yaml`, the
  `process_run` user config used by `Shell` (`var:` section with
  `accessKeyId`, `accessKeySecret`, `endpoint`, `ossTestBucketName`; see
  `.local/ds_env.example.yaml` in the package). Never commit it.
* Behaviour to code for on both sides: a missing object throws
  `OssException` with `isNotFound`; the local mock lists a `prefix` as a
  directory and its marker pagination is approximate; `putBucket` is only
  meaningful locally (guard it with `isLocalTest`); `bucket.location` is
  the region on node and the (empty) endpoint of the options locally.
* Tests: `dart_test.yaml` declares `platforms: [vm, node]`. `dart test` runs
  on the VM against the fs mock; `dart run tool/run_test_node.dart`
  (`nodeRunTest()` from `package:tekartik_build_node/build_node.dart`,
  needs `build.yaml` and `npm install`) compiles the tests to javascript and
  runs them on node against the real OSS. Skip groups with
  `skip: client == null` so a missing configuration is not a failure.

## Examples

### Shared code on the universal service

```dart
import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';

/// Real OSS on node, file system mock on the VM.
Future<void> syncConfig({
  required OssClientOptions options,
  required String bucketName,
}) async {
  var client = ossServiceUniversal.client(options: options);
  print('using $client with $options'); // secrets are obfuscated
  await client.putAsString(bucketName, 'config/app.json', '{"version": 1}');
  var response = await client.list(
    bucketName,
    OssListFilesOptions(prefix: 'config/'),
  );
  for (var file in response.files) {
    print('${file.name} ${file.size} ${file.lastModified}');
  }
}
```

### Client from the environment with the test helper

```dart
import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';
import 'package:tekartik_aliyun_oss_universal/test/environment_client.dart';

Future<void> main() async {
  // node: endpoint, accessKeyId, accessKeySecret variables required.
  // VM: mock rooted at .dart_tool/oss_fs_io, no variable needed.
  var client = ossClientTest;
  if (client == null) {
    print('missing OSS configuration: $ossClientOptionsFromEnv');
    return;
  }
  if (isLocalTest) {
    await client.putBucket('dev_bucket'); // mock only
  }
  for (var bucket in await client.listBuckets()) {
    print('${bucket.name} (${bucket.location})');
  }
}
```

### Test running on the VM (mock) and on node (real OSS)

```dart
import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';
import 'package:tekartik_aliyun_oss_universal/test/environment_client.dart';
import 'package:test/test.dart';

void main() {
  var client = ossClientTest;
  // Created locally, must exist on Aliyun.
  var bucketName = 'oss_test_bucket';

  group('oss', () {
    setUp(() async {
      if (isLocalTest) {
        await client!.putBucket(bucketName);
      }
    });

    test('put/get/delete', () async {
      var path = 'test/file.txt';
      await client!.putAsString(bucketName, path, 'Hello OSS');
      expect(await client.getAsString(bucketName, path), 'Hello OSS');
      await client.delete(bucketName, path);
      try {
        await client.getAsString(bucketName, path);
        fail('should throw');
      } on OssException catch (e) {
        expect(e.isNotFound, isTrue);
      }
    });
  }, skip: client == null);
}
```

### Unit test with the memory mock

```dart
import 'package:tekartik_aliyun_oss_fs/oss_fs.dart' show OssClientOptionsFs;
import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';
import 'package:test/test.dart';

Future<int> countObjects(OssClient client, String bucket, String prefix) async {
  var response = await client.list(bucket, OssListFilesOptions(prefix: prefix));
  return response.files.length;
}

void main() {
  test('countObjects', () async {
    var client = newOssServiceMemory().client(options: OssClientOptionsFs());
    await client.putBucket('b');
    await client.putAsString('b', 'img/1.png', 'x');
    await client.putAsString('b', 'img/2.png', 'y');
    await client.putAsString('b', 'doc/1.txt', 'z');
    expect(await countObjects(client, 'b', 'img/'), 2);
  });
}
```

### tool/run_test_node.dart

```dart
import 'package:tekartik_build_node/build_node.dart';

Future<void> main() async {
  // dart2js compile of the tests, then run with node (needs npm install).
  await nodeRunTest();
}
```

## Common mistakes

* Accessing `ossServiceNode` or `ossServiceFsIo` directly in shared code.
* `ossServiceUniversal.client()` without options on node.
* Using plain `OssClientOptions` on the VM and finding bucket directories in
  the project root.
* Forgetting `ali-oss` in `package.json` for the node build.
* Committing `.local/ds_env.yaml`.
