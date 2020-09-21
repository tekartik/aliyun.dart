import 'package:tekartik_aliyun_fc/fc_api.dart';

export 'package:tekartik_aliyun_fc/fc_api.dart';
export 'package:tekartik_aliyun_fc_universal/src/fc_universal_common.dart'
    show aliyunFunctionComputeUniversalMemory;

export 'src/fc_universal/fc.dart';

abstract class FcServer {
  Uri get uri;
  Future<void> close();
}

abstract class AliyunFunctionComputeUniversal extends AliyunFunctionCompute {
  /// No effect on node
  Future<FcServer> serve({int port});
}
