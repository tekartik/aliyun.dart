import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';
import 'package:tekartik_aliyun_oss_fs/src/import.dart';

class OssBucketFs with OssBucketMixin implements OssBucket {
  final OssClientFs client;
  @override
  String get location => client.location;

  @override
  String name;

  OssBucketFs(this.client, this.name);
}
