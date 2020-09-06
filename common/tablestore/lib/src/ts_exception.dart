/// Table store exception
abstract class TsException implements Exception {
  String get message;
  bool get isConditionFailedError;
  bool get retryable;
}
