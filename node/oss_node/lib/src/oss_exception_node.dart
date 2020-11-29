import 'package:tekartik_aliyun_oss_node/oss_node.dart';

import 'import.dart';

class OssExceptionNode implements OssException {
  final String _message;
  final Map /*?*/ map;

  @override
  String toString() => 'OssExceptionNode($message)';

  String get message =>
      _message ?? _errMapValue('message')?.toString() ?? 'error';

  dynamic _errMapValue(String key) => map != null ? map[key] : null;

  // Message can be null
  OssExceptionNode(
      {String /*?*/ message,
      this.map /*?*/
      ,
      bool isNotFound,
      bool isRetryable})
      : _message = message,
        _isNotFound = isNotFound,
        _isRetryable = isRetryable;

  // TableStoreNodeException(404:OTSObjec
  int get code => parseInt(_errMapValue('code'));

  @override
  bool get retryable =>
      _isRetryable ?? parseBool(_errMapValue('retryable')) ?? true;

  @override
  bool get isNotFound => _isNotFound ?? false;

  final bool _isNotFound;
  final bool _isRetryable;
}
