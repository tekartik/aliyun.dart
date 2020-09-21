import 'package:tekartik_aliyun_fc_universal/src/fc_universal/fc_common.dart';

export 'package:tekartik_aliyun_fc/fc_api.dart';

export 'src/fc_universal/fc.dart';

abstract class FcServer {
  Future<void> close();
}

abstract class AliyunFunctionComputeUniversal extends AliyunFunctionCompute {
  /// No effect on node
  Future<FcServer> serve({int port});
}
