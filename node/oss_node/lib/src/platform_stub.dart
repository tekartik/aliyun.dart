import 'package:tekartik_aliyun_oss_node/oss_node.dart';

/// Browser or io context.
OssService get ossServiceNode => _stub('ossServiceNode');

/// Always throw.
T _stub<T>(String message) {
  throw UnimplementedError(message);
}
