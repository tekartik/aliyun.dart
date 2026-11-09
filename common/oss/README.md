# tekartik_aliyun_oss

The runtime independent API of Aliyun OSS (object storage): `OssService`,
`OssClient` (buckets, put/get/delete/list objects). No implementation here:
`tekartik_aliyun_oss_node` uses the Aliyun SDK on nodejs,
`tekartik_aliyun_oss_fs` stores the objects in a file system (memory or io,
for tests and local runs), `tekartik_aliyun_oss_universal` picks one.

## Getting started

Git packages, not on pub.dev (a pub workspace, `path` required):

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

```dart
// Re-exports the API (package:tekartik_aliyun_oss/oss.dart, all shared code
// needs).
import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';

/// Shared code: an OssClient, whatever the implementation.
Future<String?> roundTrip(OssClient client) async {
  await client.putAsString('my-bucket', 'dir/hello.txt', 'Hello');
  var page = await client.list(
    'my-bucket',
    OssListFilesOptions(prefix: 'dir/'),
  );
  print(page.files.map((file) => file.name)); // (dir/hello.txt)
  return client.getAsString('my-bucket', 'dir/hello.txt');
}

Future<void> main() async {
  // In memory; on nodejs: ossServiceNode.client(options: OssClientOptions(...)).
  var client = newOssServiceMemory().client();
  await client.putBucket('my-bucket');
  print(await roundTrip(client)); // Hello
}
```

## Common pitfalls

* `OssClientOptions` holds the access key secret: read it from the
  environment, never from the source; its `toString` hides most of it.
* `getAsBytes`/`getAsString` return null for a missing object; `delete`
  ignores one.
* A listing is a page: go on with `options.marker = page.nextMarker` while
  `page.isTruncated` (`nextMarker` can be set on the last page).
* `putBucket` works with the fs implementation only: on nodejs, create the
  buckets in the Aliyun console.

More: the [tekartik-aliyun-oss-client skill](skills/tekartik-aliyun-oss-client/SKILL.md).
