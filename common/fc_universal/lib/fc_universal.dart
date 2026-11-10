/// One Function Compute HTTP entry point for the Dart VM (a local http server)
/// and nodejs (the Function Compute function): [aliyunFunctionComputeUniversal],
/// plus memory instances for tests
/// ([newAliyunFunctionComputeUniversalMemory]) and the re-exported
/// `tekartik_aliyun_fc` API ([FcHttpRequest], [FcHttpResponse]...).
library;

export 'package:tekartik_aliyun_fc/fc_api.dart';
export 'package:tekartik_aliyun_fc_universal/src/fc_universal_common.dart'
    show
        aliyunFunctionComputeUniversalMemory,
        newAliyunFunctionComputeUniversalMemory,
        AliyunFunctionComputeHttpUniversal,
        AliyunFunctionComputeUniversal,
        FcServer;

export 'src/fc_universal/fc.dart' show aliyunFunctionComputeUniversal;
