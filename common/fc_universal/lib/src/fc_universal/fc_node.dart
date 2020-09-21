import 'package:tekartik_aliyun_fc_node/fc_node.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_aliyun_fc_node/src/aliyun_function_compute_node.dart'; // ignore: implementation_imports

class FcServerNode implements FcServer {
  @override
  Future<void> close() async {}

  @override
  Uri get uri => null;
}

/// Can be called only once
@deprecated
void exportHttpHandler(FcHttpHandler handler, {String name = 'handler'}) =>
    aliyunFunctionComputeNode.exportHttpHandler(handler, name: name);

class AliyunFunctionComputeNodeUniversal extends AliyunFunctionComputeNode
    implements AliyunFunctionComputeUniversal {
  /// Dummy implementation on node
  @override
  Future<FcServer> serve({int port}) async => FcServerNode();
}

AliyunFunctionComputeUniversal aliyunFunctionComputeUniversal =
    AliyunFunctionComputeNodeUniversal();
