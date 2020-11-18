/// Table store exception
abstract class OssException implements Exception {
  bool get retryable;
}
