import 'package:tekartik_aliyun_tablestore/tablestore.dart';

class TsExceptionSembast implements TsException {
  @override
  final bool isConditionFailedError;

  @override
  final String message;

  /// Default. to true
  @override
  final bool retryable;

  TsExceptionSembast(
      {this.isConditionFailedError, this.message, bool retryable = true})
      : retryable = retryable ?? true;
}
