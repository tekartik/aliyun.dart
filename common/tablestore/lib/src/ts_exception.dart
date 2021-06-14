/// Table store exception
abstract class TsException implements Exception {
  String get message;

  bool get isConditionFailedError;

  bool get isTableNotExistError;

  bool get isPrimaryKeySizeError;

  bool get isPrimaryKeyTypeError;

  bool get retryable;
}
