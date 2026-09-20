---
name: tekartik-aliyun-oss-fs-setup
description: >-
  Use when you need an Aliyun OSS mock backed by a file system (fs_shim) for
  unit tests or local development with tekartik_aliyun_oss_fs:
  ossServiceMemory, newOssServiceMemory, ossServiceFsIo, OssClientOptionsFs
  with rootPath, the package:tekartik_aliyun_oss_fs/oss_fs.dart and
  oss_fs_io.dart imports, the <rootPath>/<bucket>/<object path> layout,
  OssException isNotFound behaviour, prefix and marker listing limits of the
  mock, and injecting an OssService into code written against
  tekartik_aliyun_oss (OssClient, putAsString, getAsString, list).
---

# OSS mock on a file system (tekartik_aliyun_oss_fs)

`tekartik_aliyun_oss_fs` implements the `tekartik_aliyun_oss` API on an
`fs_shim` file system: a bucket is a directory, an object is a file. In memory
it is the unit test double; on `dart:io` it is a local stand-in for a real
bucket (`tekartik_aliyun_oss_universal` uses it whenever the code does not run
on node).

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_aliyun_oss_fs:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/oss_fs
    tekartik_aliyun_oss:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/oss
  ```
* Imports: `package:tekartik_aliyun_oss_fs/oss_fs.dart` re-exports
  `tekartik_aliyun_oss/oss.dart` and adds `ossServiceMemory` (shared in
  memory service), `newOssServiceMemory([name])` (a fresh, isolated one) and
  `OssClientOptionsFs`; it works on every platform.
  `package:tekartik_aliyun_oss_fs/oss_fs_io.dart` re-exports it and adds
  `ossServiceFsIo` on the real file system (`fs_shim` `fileSystemIo`); on
  the web that getter throws `UnimplementedError`. `ossServiceFsMemory` and
  `newOssServiceFsMemory` are deprecated aliases. A service on another
  `fs_shim` file system is not reachable from the public libraries.
* Always pass an `OssClientOptionsFs()` to `client(options:)`: without
  options `bucket.location` (and `bucket.toString()`) throws, and on io the
  buckets land in the current directory.
  `OssClientOptionsFs()..rootPath = '.dart_tool/oss_fs_io'` roots the
  buckets under `rootPath` (relative to the current directory, or
  absolute); its credentials and `endpoint` are empty strings and
  `bucket.location` is that empty endpoint. A plain `OssClientOptions` also
  works (its `endpoint` becomes the location) but has no root path.
* Layout: `<rootPath>/<bucketName>/<object path>`; `putAsBytes`/`putAsString`
  create the parent directories. `putBucket` creates the bucket directory,
  `getBucket` throws an `OssException` (`isNotFound`) when it is missing,
  `listBuckets` lists the directories under the root. Nothing is cleaned up
  on io: delete the root directory yourself for a blank state (in memory,
  `newOssServiceMemory()` is blank).
* Missing object: `getAsBytes`/`getAsString` throw an `OssException` with
  `isNotFound == true` (they never return null); `delete` swallows every
  error.
* `list(bucket, OssListFilesOptions(prefix:, maxResults:, marker:))` treats
  `prefix` as a directory path (`<bucket>/<prefix>` is listed recursively),
  not as a string prefix like real OSS: `prefix: 'dir'` or `'dir/'` lists
  `dir/**`, `prefix: 'dir/fi'` lists nothing. Use directory-like prefixes
  so the code behaves the same on both. Names are `/`-separated paths
  relative to the bucket, sorted; `maxResults` (default 1000) truncates and
  sets `isTruncated`/`nextMarker`. Marker pagination is approximate in the
  current implementation (resuming at a marker skips entries when more
  than one remains): in tests keep `maxResults` above the object count and
  do not assert on multi-page results against the mock.
* Create the `OssService` in `main` or in the test `setUp` and hand it (or
  the `OssClient`) to the code under test; production code depends on
  `tekartik_aliyun_oss` only.
* Tests run with `dart test` (VM). `test/oss_fs_test.dart` (memory) and
  `test/oss_fs_io_test.dart` (io) in the package are the reference.

## Examples

### In memory round trip

```dart
import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';

Future<void> main() async {
  var service = newOssServiceMemory();
  var client = service.client(options: OssClientOptionsFs());

  var bucket = await client.putBucket('my_bucket');
  await client.putAsString(bucket.name, 'notes/hello.txt', 'Hello OSS');
  print(await client.getAsString(bucket.name, 'notes/hello.txt')); // Hello OSS

  var response = await client.list(
    bucket.name,
    OssListFilesOptions(prefix: 'notes/'),
  );
  for (var file in response.files) {
    print('${file.name} ${file.size} ${file.lastModified}');
  }
  await client.delete(bucket.name, 'notes/hello.txt');
}
```

### Local io service rooted under .dart_tool

```dart
import 'package:tekartik_aliyun_oss_fs/oss_fs_io.dart';

/// Files end up in .dart_tool/oss_fs_io/<bucket>/<object path>.
OssClient openLocalOssClient() => ossServiceFsIo.client(
  options: OssClientOptionsFs()..rootPath = '.dart_tool/oss_fs_io',
);

Future<void> main() async {
  var client = openLocalOssClient();
  await client.putBucket('dev_bucket');
  await client.putAsString('dev_bucket', 'config.json', '{"debug": true}');
  for (var bucket in await client.listBuckets()) {
    print(bucket.name);
  }
}
```

### Unit test: isolated service, not found handling, listing

```dart
import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';
import 'package:test/test.dart';

void main() {
  late OssClient client;
  setUp(() async {
    client = newOssServiceMemory().client(options: OssClientOptionsFs());
    await client.putBucket('test');
  });

  test('missing object and bucket', () async {
    try {
      await client.getAsString('test', 'missing.txt');
      fail('should throw');
    } on OssException catch (e) {
      expect(e.isNotFound, isTrue);
    }
    await client.delete('test', 'missing.txt'); // no error

    try {
      await client.getBucket('other');
      fail('should throw');
    } on OssException catch (e) {
      expect(e.isNotFound, isTrue);
    }
  });

  test('list under a prefix', () async {
    await client.putAsString('test', 'dir/a.txt', 'a');
    await client.putAsString('test', 'dir/sub/b.txt', 'bb');
    await client.putAsString('test', 'other/c.txt', 'c');

    var response = await client.list('test', OssListFilesOptions(prefix: 'dir/'));
    expect(response.isTruncated, isFalse);
    expect(response.files.map((e) => e.name), ['dir/a.txt', 'dir/sub/b.txt']);
    expect(response.files.last.size, 2);
  });
}
```

### Inject the service into code written against tekartik_aliyun_oss

```dart
import 'package:tekartik_aliyun_oss_fs/oss_fs_io.dart';

/// Shared code only knows OssService.
class Uploader {
  final OssClient client;
  Uploader(OssService service, OssClientOptions options)
    : client = service.client(options: options);

  Future<void> upload(String bucket, String path, String text) =>
      client.putAsString(bucket, path, text);
}

/// main picks the implementation: memory for tests, io locally.
Uploader newUploader({bool inMemory = false}) => Uploader(
  inMemory ? newOssServiceMemory() : ossServiceFsIo,
  OssClientOptionsFs()..rootPath = '.dart_tool/oss_fs_io',
);
```

## Common mistakes

* `service.client()` without options, then reading `bucket.location`.
* Expecting `getAsString` to return null for a missing object.
* Using a string prefix (`'dir/fi'`) that is not a directory path.
* Asserting on multi-page `marker` results against the mock.
* Sharing `ossServiceMemory` between tests that expect a blank state.
