// ignore_for_file: avoid_print

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
