// JS:
// {"message":"\n\u0011OTSObjectNotExist\u0012\u001fRequested table does not exist.","code":404,"headers":{"date":"Fri, 04 Sep 2020 08:20:18 GMT","transfer-encoding":"chunked","connection":"keep-alive","authorization":"OTS LTAI4GCzUBNEhUsjDMwxrpHs:mE9Ca6pH7IeIqUxFyOblMZVj9Lg=","x-ots-contentmd5":"e2enEqtXyX/3YTqhbiPDtw==","x-ots-contenttype":"protocol buffer","x-ots-date":"2020-09-04T08:20:18.991322Z","x-ots-requestid":"0005ae78-8a0d-52c0-e6c1-720b05604f7b"},"time":{},"retryable":false}
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

import 'import.dart';

class TsExceptionNode implements TsException {
  final String? _message;
  final Map? map;

  @override
  String get message =>
      _message ?? _errMapValue('message')?.toString() ?? 'error';

  dynamic _errMapValue(String key) => map != null ? map![key] : null;

  // Message can be null
  TsExceptionNode({String? message, this.map /*?*/}) : _message = message;

  // TableStoreNodeException(404:OTSObjec
  int? get code => parseInt(_errMapValue('code'));

  @override
  bool get retryable => parseBool(_errMapValue('retryable')) ?? true;

  bool get isNotFound => code == httpStatusCodeNotFound;

  bool get isForbidden403 => code == httpStatusCodeForbidden;

  bool get isBadRequest400 => code == httpStatusCodeBadRequest;

  @override
  String toString() => 'TableStoreNodeException($message, $map)';

  // JS: condition failed
  // {"message":"\n\u0015OTSConditionCheckFail\u0012\u0017Condition check failed.","code":403,"headers":{"date":"Sun, 06 Sep 2020 06:33:01 GMT","transfer-encoding":"chunked","connection":"keep-alive","authorization":"OTS LTAI4GCzUBNEhUsjDMwxrpHs:VrOVjJHFxuRacGHrnl71NW+fC0Q=","x-ots-contentmd5":"tb1xxFT1i9oAap/9e+zMLA==","x-ots-contenttype":"protocol buffer","x-ots-date":"2020-09-06T06:33:01.163851Z","x-ots-requestid":"0005ae9f-4602-9e74-a5c1-720b0df7d216"},"time":{},"retryable":false}
  @override
  bool get isConditionFailedError =>
      isForbidden403 ||
      message.toLowerCase().contains('condition check failed');

  @override
  bool get isTableNotExistError =>
      isBadRequest400 && message.toLowerCase().contains('table not exist');

  @override
  bool get isPrimaryKeySizeError =>
      isBadRequest400 && message.toLowerCase().contains('pk size fail');

  // Validate PK type fail
  @override
  bool get isPrimaryKeyTypeError =>
      isBadRequest400 && message.toLowerCase().contains('pk type fail');
}
