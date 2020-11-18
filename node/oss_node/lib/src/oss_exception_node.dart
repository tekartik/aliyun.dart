import 'package:tekartik_aliyun_oss_node/oss_service.dart';

import 'import.dart';

class OssExceptionNode implements OssException {
  final String _message;
  final Map /*?*/ map;

  String get message =>
      _message ?? _errMapValue('message')?.toString() ?? 'error';

  dynamic _errMapValue(String key) => map != null ? map[key] : null;

  // Message can be null
  OssExceptionNode({String /*?*/ message, this.map /*?*/
      })
      : _message = message;

  // TableStoreNodeException(404:OTSObjec
  int get code => parseInt(_errMapValue('code'));

  @override
  bool get retryable => parseBool(_errMapValue('retryable')) ?? true;
}
