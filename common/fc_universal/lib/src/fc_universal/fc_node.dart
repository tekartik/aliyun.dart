import 'package:tekartik_aliyun_fc_node/src/aliyun_function_compute_node.dart'; // ignore: implementation_imports
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';

class FcServerNode implements FcServer {
  @override
  Future<void> close() async {}

  @override
  Uri? get uri => null;
}

/// Node implementation
class AliyunFunctionComputeNodeUniversal extends AliyunFunctionComputeNode
    implements AliyunFunctionComputeUniversal {
  /// Dummy implementation on node
  @override
  Future<FcServer> serve({int? port}) async => FcServerNode();
}

AliyunFunctionComputeUniversal aliyunFunctionComputeUniversal =
    AliyunFunctionComputeNodeUniversal();
