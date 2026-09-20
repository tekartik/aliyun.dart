---
name: tekartik-aliyun-oss-client
description: >-
  Use when reading, writing, deleting or listing objects in Aliyun OSS buckets
  through the runtime-neutral tekartik_aliyun_oss API: OssService.client,
  OssClientOptions (accessKeyId, accessKeySecret, endpoint), OssClient
  (listBuckets, getBucket, putBucket, putAsString, getAsString, putAsBytes,
  getAsBytes, delete, list), OssBucket, OssFile, OssListFilesOptions and
  OssListFilesResponse pagination (prefix, maxResults, marker, isTruncated,
  nextMarker), OssException (isNotFound, retryable), the
  package:tekartik_aliyun_oss/oss.dart import, and implementing a custom
  service or test double with OssServiceMixin, OssClientMixin, OssBucketMixin.
---

# OSS client API (tekartik_aliyun_oss)

`tekartik_aliyun_oss` defines the Aliyun Object Storage Service API used by
Tekartik Dart code: a service that opens clients, a client that manipulates
buckets and objects by name. It has no network code. Implementations:
`tekartik_aliyun_oss_fs` (mock on a file system, memory or io),
`tekartik_aliyun_oss_node` (the `ali-oss` npm module, nodejs only) and
`tekartik_aliyun_oss_universal` (node or fs mock, picked at compile time).
Write business code against `OssService`/`OssClient` and inject the
implementation.

## Guidelines

* Dependency (git, not on pub.dev; the repo is a pub workspace, `path` is
  required):
  ```yaml
  dependencies:
    tekartik_aliyun_oss:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/oss
  ```
* Import `package:tekartik_aliyun_oss/oss.dart`, the only public library
  (the implementation packages re-export it).
* `OssService.client({OssClientOptions? options})` returns an `OssClient`.
  `OssClientOptions(accessKeyId:, accessKeySecret:, endpoint:)` holds the
  credentials and the OSS endpoint (`oss-<region>.aliyuncs.com`); its
  `toString()` obfuscates the values, it is safe to log. The node service
  requires options; the fs mock accepts `null` or its own
  `OssClientOptionsFs`.
* Buckets: `listBuckets()` gives `OssBucket`s (`name`, `location`);
  `getBucket(name)` throws an `OssException` with `isNotFound` when the
  bucket does not exist; `putBucket(name)` is documented as mock only
  (create real buckets in the console).
* Objects are addressed by `(bucketName, path)` where `path` is the object
  key (`'dir/file.txt'`, no leading `/`): `putAsString`/`getAsString`
  (utf-8), `putAsBytes`/`getAsBytes` (`Uint8List`), `delete` (silent when
  the object is absent). `getAsBytes`/`getAsString` are typed nullable but
  the fs and node implementations throw an `OssException` with
  `isNotFound == true` for a missing object: handle both (null result and
  exception) in shared code.
* Listing: `list(bucketName, OssListFilesOptions(prefix:, maxResults:, marker:))`
  returns an `OssListFilesResponse`: `files` (`OssFile.name`, `size`,
  `lastModified`), `isTruncated`, `nextMarker`. `maxResults` defaults to
  1000. Page by setting `options.marker = response.nextMarker` (`marker` is
  the only mutable field) and calling again while `isTruncated` is true;
  `nextMarker` may be non null on the last page, only `isTruncated` ends
  the loop. `OssListFilesOptions.toString()` prints the set fields.
* `OssException` exposes `isNotFound` and `retryable`; the node
  implementation retries retryable failures itself. Catch `OssException`,
  not implementation types, in shared code.
* `debugAliyunOss` (getter) enables implementation logging; its setter is
  `@Deprecated('Dev only')`, flip it in a debugging session only.
* Implementing a service (test double or new backend): `OssServiceMixin` on
  the `OssService`, `OssClientMixin` on the `OssClient` (provides
  `putAsString`/`getAsString` on top of the bytes methods; every other
  method throws `UnimplementedError` until overridden), `OssBucketMixin` on
  the `OssBucket` (`toDebugMap()` as a `cv` `Model`, `toString`). Throw an
  `OssException` implementation with `isNotFound` for missing objects.
* There is no shared conformance test package; the
  `tekartik_aliyun_oss_universal` tests (`test/oss_universal_test.dart`)
  are the reference behaviour (put/get/delete, prefix listing with
  `maxResults: 2`, stable `lastModified` and `size` between two lists).

## Examples

### Repository written against the abstract client

```dart
import 'dart:convert';

import 'package:tekartik_aliyun_oss/oss.dart';

class JsonStore {
  final OssClient client;
  final String bucketName;

  JsonStore(this.client, this.bucketName);

  String _path(String key) => 'json/$key.json';

  Future<void> write(String key, Map<String, Object?> json) =>
      client.putAsString(bucketName, _path(key), jsonEncode(json));

  /// null when the object does not exist (null result or not found error).
  Future<Map<String, Object?>?> read(String key) async {
    try {
      var text = await client.getAsString(bucketName, _path(key));
      if (text == null) {
        return null;
      }
      return jsonDecode(text) as Map<String, Object?>;
    } on OssException catch (e) {
      if (e.isNotFound) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> remove(String key) => client.delete(bucketName, _path(key));
}
```

### Client options from a configuration map, bucket listing

```dart
import 'package:tekartik_aliyun_oss/oss.dart';

OssClientOptions? ossClientOptionsFrom(Map<String, String> env) {
  var endpoint = env['endpoint'];
  var accessKeyId = env['accessKeyId'];
  var accessKeySecret = env['accessKeySecret'];
  if (endpoint == null || accessKeyId == null || accessKeySecret == null) {
    return null;
  }
  return OssClientOptions(
    endpoint: endpoint,
    accessKeyId: accessKeyId,
    accessKeySecret: accessKeySecret,
  );
}

Future<void> printBuckets(OssService service, Map<String, String> env) async {
  var options = ossClientOptionsFrom(env);
  if (options == null) {
    print('missing endpoint, accessKeyId or accessKeySecret');
    return;
  }
  print('options: $options'); // secrets are obfuscated
  var client = service.client(options: options);
  for (var bucket in await client.listBuckets()) {
    print('${bucket.name} (${bucket.location})');
  }
}
```

### Paginated listing under a prefix

```dart
import 'package:tekartik_aliyun_oss/oss.dart';

/// Every object name under [prefix], fetched by pages of [pageSize].
Future<List<String>> listAllNames(
  OssClient client,
  String bucketName, {
  required String prefix,
  int pageSize = 100,
}) async {
  var names = <String>[];
  var options = OssListFilesOptions(prefix: prefix, maxResults: pageSize);
  while (true) {
    var response = await client.list(bucketName, options);
    for (var file in response.files) {
      names.add(file.name); // also file.size, file.lastModified
    }
    if (!response.isTruncated) {
      break;
    }
    options.marker = response.nextMarker;
  }
  return names;
}

/// Bytes helpers.
Future<void> copyObject(
  OssClient client,
  String bucketName,
  String from,
  String to,
) async {
  var bytes = await client.getAsBytes(bucketName, from);
  if (bytes != null) {
    await client.putAsBytes(bucketName, to, bytes);
  }
}
```

### Minimal in-memory implementation with the mixins

```dart
import 'dart:typed_data';

import 'package:tekartik_aliyun_oss/oss.dart';

/// Test double: a map per bucket; list() is left unimplemented.
class MapOssService with OssServiceMixin {
  final buckets = <String, Map<String, Uint8List>>{};

  @override
  OssClient client({OssClientOptions? options}) => MapOssClient(this);
}

class MapOssBucket with OssBucketMixin {
  @override
  final String name;

  @override
  String get location => 'memory';

  MapOssBucket(this.name);
}

class MapOssException implements OssException {
  final String message;

  @override
  final bool isNotFound;

  @override
  bool get retryable => false;

  MapOssException(this.message, {this.isNotFound = false});

  @override
  String toString() => 'MapOssException($message)';
}

class MapOssClient with OssClientMixin {
  final MapOssService service;

  MapOssClient(this.service);

  Map<String, Uint8List> _bucket(String name) =>
      service.buckets[name] ??
      (throw MapOssException('bucket $name not found', isNotFound: true));

  @override
  Future<List<OssBucket>> listBuckets() async =>
      service.buckets.keys.map(MapOssBucket.new).toList();

  @override
  Future<OssBucket> putBucket(String name) async {
    service.buckets.putIfAbsent(name, () => {});
    return MapOssBucket(name);
  }

  @override
  Future<OssBucket> getBucket(String name) async {
    _bucket(name);
    return MapOssBucket(name);
  }

  @override
  Future<void> putAsBytes(
    String bucketName,
    String path,
    Uint8List bytes,
  ) async {
    _bucket(bucketName)[path] = bytes;
  }

  @override
  Future<Uint8List?> getAsBytes(String bucketName, String path) async =>
      _bucket(bucketName)[path] ??
      (throw MapOssException('$path not found', isNotFound: true));

  @override
  Future<void> delete(String bucketName, String path) async {
    service.buckets[bucketName]?.remove(path);
  }
}
```

## Common mistakes

* Assuming `getAsString`/`getAsBytes` return null for a missing object: the
  existing implementations throw `OssException` (`isNotFound`).
* Stopping pagination on `nextMarker == null` instead of `isTruncated`.
* Building a new `OssListFilesOptions` for the next page instead of
  updating `marker` (or forgetting to carry `prefix` and `maxResults`).
* Object keys with a leading `/`.
* Depending on an implementation package from shared code; only `main` and
  tests should pick `ossServiceMemory`, `ossServiceFsIo`, `ossServiceNode`.
