import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';

class OssExceptionFs implements OssException {
  @override
  String toString() => 'OssExceptionFs()';

  /// Default. to true
  @override
  final bool retryable;

  OssExceptionFs({this.retryable = false, this.isNotFound = false});

  @override
  final bool isNotFound;
}
