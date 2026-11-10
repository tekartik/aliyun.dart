# tekartik_aliyun_oss_universal

One Aliyun OSS (object storage) service for code that runs both on the Dart
VM and on nodejs: `ossServiceUniversal` is the real OSS over the `ali-oss`
npm module when compiled to JavaScript for node (`tekartik_aliyun_oss_node`,
typically in a Function Compute function), and a file system mock on the
Dart VM (`tekartik_aliyun_oss_fs`). The whole `tekartik_aliyun_oss` API and
the memory mock are re-exported.

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_aliyun_oss_universal:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/oss_universal
```

For node, a `package.json` with `"ali-oss": "^6.11.2"` and `npm install`.

```dart
import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';

Future<void> upload(OssClientOptions options) async {
  // node: the real OSS (options mandatory); VM: files in the current folder.
  var client = ossServiceUniversal.client(options: options);
  await client.putAsString('my-bucket', 'notes/hello.txt', 'Hello');
  var page = await client.list(
    'my-bucket',
    OssListFilesOptions(prefix: 'notes/'),
  );
  print(page.files.map((file) => file.name));
}
```

[example/main.dart](example/main.dart) (`dart run example/main.dart`) uses
the test helper `package:tekartik_aliyun_oss_universal/test/environment_client.dart`:
`ossClientTest` is a mock rooted at `.dart_tool/oss_fs_io` on the VM and the
real OSS from the `endpoint`, `accessKeyId` and `accessKeySecret` environment
variables on node.

In unit tests, `newOssServiceMemory().client(options: OssClientOptionsFs())`
is an empty in memory service on every platform (`OssClientOptionsFs`:
add the `tekartik_aliyun_oss_fs` git dependency, `path: common/oss_fs`).

## Platforms

* nodejs (dart2js): `ossServiceUniversal` is `ossServiceNode`.
* Dart VM: `ossServiceUniversal` is `ossServiceFsIo` (a bucket is a folder,
  an object a file).
* Memory (`ossServiceMemory`, `newOssServiceMemory()`): every platform.
* Browser: not supported.

## Common pitfalls

* On the VM the files go to the current folder unless the options are an
  `OssClientOptionsFs` with a `rootPath`.
* A missing object throws an `OssException` whose `isNotFound` is true.
* `prefix` is a string prefix of the key (`dir` also lists `dir.txt`).
  Page with `options.marker = page.nextMarker`: the mock marker is
  inclusive, the OSS one exclusive.
* `putBucket` only makes sense on the mock (`isLocalTest`); on OSS the
  bucket must exist.
* Credentials: environment variables on node, the process_run user config
  (`.local/ds_env.yaml`, git-ignored) on the VM; never commit them.

## Testing

```bash
dart test                         # vm, against the mock
dart run tool/run_test_node.dart  # node, against OSS (credentials and ossTestBucketName)
```
