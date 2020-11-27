import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';

import 'import.dart';

class OssExceptionFs implements OssException {
  @override
  String toString() => 'OssExceptionFs($message)';

  final String message;
  /// Default. to true
  @override
  final bool retryable;

  OssExceptionFs({@required this.message, this.retryable = false, this.isNotFound = false});

  @override
  final bool isNotFound;
}
