import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/import.dart';

class TsExceptionSembast implements TsException {
  @override
  final bool isConditionFailedError;

  @override
  final String message;

  /// Default. to true
  @override
  final bool retryable;

  TsExceptionSembast(
      {this.isConditionFailedError = false,
      @required this.message,
      this.retryable = false});

  @override
  String toString() => '$message, retryable: $retryable';
}
