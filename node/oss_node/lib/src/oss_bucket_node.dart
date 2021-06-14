import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:tekartik_aliyun_oss_node/src/oss_interop.dart';

class OssBucketNode with OssBucketMixin implements OssBucket {
  @override
  late String name;

  @override
  String toString() => 'bucket $name';

  @override
  late String location;
}

OssBucket wrapNativeBucket(OssClientListBucketJs nativeBucket) {
  return OssBucketNode()
    ..name = nativeBucket.name
    ..location = nativeBucket.region;
}

OssBucket wrapNativeBucketInfo(OssClientBucketInfoJs bucketInfoJs) {
  return OssBucketNode()
    ..name = bucketInfoJs.Name
    ..location = bucketInfoJs.Location;
}

List<OssBucket> wrapNativeBuckets(List list) =>
    list.cast<OssClientListBucketJs>().map((e) => wrapNativeBucket(e)).toList();
