/// Table store exception
abstract class OssException implements Exception {
  /// Can retry the operation
  bool get retryable;

  /// not found exception
  bool get isNotFound;
}
