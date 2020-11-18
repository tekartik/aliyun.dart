import 'package:tekartik_aliyun_oss/oss.dart';

bool debugAliyunOss = true; // devWarning(true); true for now until it works

abstract class OssService {
  OssClient client({OssClientOptions options});
}

mixin OssServiceMixin implements OssService {}
