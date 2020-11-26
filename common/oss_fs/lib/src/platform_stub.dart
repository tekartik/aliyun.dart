import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';

/// Browser or io context.
OssService get ossServiceFsIo => _stub('ossServiceFsIo');

/// Always throw.
T _stub<T>(String message) {
  throw UnimplementedError(message);
}
