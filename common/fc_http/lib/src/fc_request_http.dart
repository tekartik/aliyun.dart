import 'dart:convert';
import 'dart:typed_data';
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_http/http.dart' as impl;

class FcHttpRequestHttp implements FcHttpRequest {
  final impl.HttpRequest requestImpl;
  Uint8List _body;

  final _bodyLock = Lock();
  Future<Uint8List> _readBody() async {
    if (_body != null) {
      return _body;
    }

    return _bodyLock.synchronized(() async {
      if (_body != null) {
        return _body;
      }
      var list = await requestImpl.toList();
      return Uint8List.fromList(list.expand((element) => element).toList());
    });
  }

  FcHttpRequestHttp(this.requestImpl);

  @override
  Future<String> getBodyString() async {
    var body = await _readBody();
    return utf8.decode(body);
  }

  @override
  String get method => requestImpl.method;

  @override
  String get path => requestImpl.uri.path;

  @override
  String get url => requestImpl.uri.toString();

  @override
  Map<String, String> get headers {
    var headers = <String, String>{};
    requestImpl.headers.forEach((name, values) {
      headers[name] = values.join(',');
    });
    return headers;
  }
}
