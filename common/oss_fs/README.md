# tekartik_aliyun_oss_fs

An Aliyun OSS (object storage) implementation of the `tekartik_aliyun_oss` API
on a file system (`fs_shim`): a bucket is a directory, an object is a file. In
memory it is a test double, on `dart:io` a local stand-in for real buckets.

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_aliyun_oss:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/oss
  tekartik_aliyun_oss_fs:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/oss_fs
```

In memory ([example/main.dart](example/main.dart), `dart run example/main.dart`):

```dart
import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';

Future<void> main() async {
  var client = newOssServiceMemory().client(options: OssClientOptionsFs());
  await client.putBucket('my-bucket');
  await client.putAsString('my-bucket', 'notes/hello.txt', 'Hello');
  print(await client.getAsString('my-bucket', 'notes/hello.txt')); // Hello

  var page = await client.list(
    'my-bucket',
    OssListFilesOptions(prefix: 'notes/'),
  );
  print(page.files.map((file) => file.name)); // (notes/hello.txt)
}
```

On the file system (Dart VM): `ossServiceFsIo` from
`package:tekartik_aliyun_oss_fs/oss_fs_io.dart`, with
`OssClientOptionsFs()..rootPath = '.dart_tool/oss'`: objects are stored in
`<rootPath>/<bucket>/<key>`.

## Platforms

* `oss_fs.dart` (memory: `ossServiceMemory` shared, `newOssServiceMemory()`
  empty): every platform.
* `oss_fs_io.dart` (`ossServiceFsIo`): Dart VM and Flutter native; the getter
  throws `UnimplementedError` on the web.

## Common pitfalls

* Pass `OssClientOptionsFs()` to `client(options:)`: without options
  `bucket.location` throws, and on io the buckets are created in the current
  directory.
* A missing object: `getAsBytes`/`getAsString` throw an `OssException` whose
  `isNotFound` is true (as on nodejs); `delete` ignores it.
* `prefix` is a string prefix of the key, like OSS: `'dir'` lists `dir.txt`,
  `dir/a.txt` and `dir2/b.txt`.
* `marker` is inclusive and `nextMarker` is the first key of the next page;
  on OSS the marker is exclusive and `nextMarker` the last key returned. Page
  with `options.marker = page.nextMarker`, which works on both, but do not
  pass a key you already got as marker.
* Keys are file paths here: a key with `..` segments or starting with `/`
  leaves the bucket (and the `rootPath` on io). Never use a key coming from
  a user as is.

## Testing

```bash
dart test
```
