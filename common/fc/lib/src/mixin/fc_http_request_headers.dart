import 'dart:collection';

class FcHttpRequestHeaders with MapMixin<String, String> {
  final Map<String, String> lowerCaseHeaders;

  FcHttpRequestHeaders(this.lowerCaseHeaders);

  @override
  String? operator [](Object? key) {
    return lowerCaseHeaders[key?.toString().toLowerCase()];
  }

  @override
  void operator []=(String key, String value) {
    throw StateError('read-only');
  }

  @override
  void clear() {
    throw StateError('read-only');
  }

  @override
  Iterable<String> get keys => lowerCaseHeaders.keys;

  @override
  String remove(Object? key) {
    throw StateError('read-only');
  }
}
