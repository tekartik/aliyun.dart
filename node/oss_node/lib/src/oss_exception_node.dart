import 'package:tekartik_aliyun_oss_node/oss_node.dart';

import 'import.dart';

class OssExceptionNode implements OssException {
  final String? _message;
  final Map? map;

  @override
  String toString() => 'OssExceptionNode($message)';

  String get message =>
      _message ?? _errMapValue('message')?.toString() ?? 'error';

  dynamic _errMapValue(String key) => map != null ? map![key] : null;

  // Message can be null
  OssExceptionNode({
    this._message,
    this.map /*?*/,
    this._isNotFound,
    this._isRetryable,
  });

  // TableStoreNodeException(404:OTSObjec
  int? get code => parseInt(_errMapValue('code'));

  /// The http status of the native (ali-oss) error, if any.
  ///
  /// Network errors have none (or a negative one).
  int? get status => parseInt(_errMapValue('status'));

  bool get _isClientError {
    var status = this.status;
    return status != null && status >= 400 && status < 500;
  }

  /// A client error (4xx: not found, access denied, bad request...) is not
  /// retryable.
  @override
  bool get retryable =>
      _isRetryable ?? parseBool(_errMapValue('retryable')) ?? !_isClientError;

  /// True for a 404 (missing bucket or key).
  @override
  bool get isNotFound => _isNotFound ?? (status == 404);

  final bool? _isNotFound;
  final bool? _isRetryable;
}
