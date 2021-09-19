import 'package:tekartik_aliyun_oss/oss.dart';

bool _debugAliyunOss = false; // devWarning(true); true for now until it works
bool get debugAliyunOss => _debugAliyunOss;

@Deprecated('Dev only')
set debugAliyunOss(bool debug) => _debugAliyunOss = debug;

abstract class OssService {
  OssClient client({OssClientOptions? options});
}

mixin OssServiceMixin implements OssService {}
