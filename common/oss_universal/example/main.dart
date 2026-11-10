// ignore_for_file: avoid_print

import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';
import 'package:tekartik_aliyun_oss_universal/test/environment_client.dart';

/// Dart VM: the file system mock, objects under `.dart_tool/oss_fs_io`.
/// nodejs: the real OSS, from the `endpoint`, `accessKeyId` and
/// `accessKeySecret` environment variables (the bucket must exist).
Future<void> main() async {
  var client = ossClientTest;
  if (client == null) {
    print('missing OSS configuration');
    return;
  }
  var bucketName = 'example-bucket';
  if (isLocalTest) {
    await client.putBucket(bucketName); // mock only
  }
  await client.putAsString(bucketName, 'notes/hello.txt', 'Hello');
  print(await client.getAsString(bucketName, 'notes/hello.txt')); // Hello
  var page = await client.list(
    bucketName,
    OssListFilesOptions(prefix: 'notes/'),
  );
  print(page.files.map((file) => file.name)); // (notes/hello.txt)
}
