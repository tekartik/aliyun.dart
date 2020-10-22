import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_http/http.dart' as impl;

class FcHttpRequestHeaders with MapMixin<String, String> {
  final Map<String, String> lowerCaseHeaders;

  FcHttpRequestHeaders(this.lowerCaseHeaders);

  @override
  String operator [](Object key) {
    return lowerCaseHeaders[key?.toString()?.toLowerCase()];
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
  String remove(Object key) {
    throw StateError('read-only');
  }
}

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

  FcHttpRequestHeaders _headers;
  @override
  Map<String, String> get headers => _headers ??= () {
        var lowerCaseHaders = <String, String>{};
        requestImpl.headers.forEach((name, values) {
          lowerCaseHaders[name.toLowerCase()] = values.join(',');
        });
        return FcHttpRequestHeaders(lowerCaseHaders);
      }();

  @override
  Future<Uint8List> getBodyBytes() {
    return _readBody();
  }
}
