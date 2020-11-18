import 'package:tekartik_aliyun_oss_node/oss_service.dart';
import 'package:tekartik_aliyun_oss_node/src/oss_interop.dart';

class OssBucketNode implements OssBucket {
  @override
  String name;

  @override
  String toString() => 'bucket $name';
}

OssBucket wrapNativeBucket(OssClientListBucketJs nativeBucket) {
  return OssBucketNode()..name = nativeBucket.name;
}

List<OssBucket> wrapNativeBuckets(List list) =>
    list.cast<OssClientListBucketJs>().map((e) => wrapNativeBucket(e)).toList();
