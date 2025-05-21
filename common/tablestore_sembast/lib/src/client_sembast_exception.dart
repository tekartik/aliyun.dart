import 'package:tekartik_aliyun_tablestore/tablestore.dart';

class TsExceptionSembast implements TsException {
  @override
  final bool isConditionFailedError;

  @override
  final bool isTableNotExistError;

  @override
  final bool isPrimaryKeySizeError;

  @override
  final String message;

  @override
  final bool isPrimaryKeyTypeError;

  /// Default. to true
  @override
  final bool retryable;

  TsExceptionSembast({
    this.isConditionFailedError = false,
    this.isTableNotExistError = false,
    this.isPrimaryKeySizeError = false,
    this.isPrimaryKeyTypeError = false,
    required this.message,
    this.retryable = false,
  });

  @override
  String toString() => '$message, retryable: $retryable';
}
