@JS()
library tekartik_aliyun_fc_node.fc_interop;

import 'dart:js_util';

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_js_utils/js_utils.dart';

@JS()
@anonymous
class _HttpResponseJs {
  external void send(String body);
}

@JS()
@anonymous
class _HttpReqJs {
  external String get url;

  external Map<String, dynamic> get queries;
}

@JS()
@anonymous
class _HttpContextJs {
  external Map<String, dynamic> get credentials;
}

typedef _GetBodyFn = dynamic Function(dynamic req, [dynamic option]);

_GetBodyFn _getRawBodyFn = require('raw-body');

/*
// Example
var getRawBody = require('raw-body')
getRawBody(request, function(err, data){
  var body = data
})

 */

// ["requestId","credentials","function","service","region","accountId","logger","retryCount"]
class FcHttpContextJs implements FcHttpContext {
  final _HttpContextJs native;

  FcHttpContextJs(this.native);

  Map<String, dynamic> get credentials => jsObjectAsMap(native.credentials);

  @override
  String toString() {
    var map = <String, dynamic>{
      'credentials': credentials,
    };
    return map.toString();
  }
}

// ["_events","_eventsCount","_maxListeners","method","clientIP","url","path","queries","headers","getHeader"
class FcHttpRequestJs implements FcHttpRequest {
  final _HttpReqJs req;
  Future _rawBody;

  FcHttpRequestJs(this.req);

  Future getRawBody() {
    return _rawBody ??= promiseToFuture(_getRawBodyFn(req));
  }

  Future _getRawBody({bool encoding}) {
    return _rawBody ??=
        promiseToFuture(_getRawBodyFn(req, jsify({'encoding': encoding})));
  }

  @override
  Future<String> getBodyString() async {
    var buff = await _getRawBody(encoding: true);
    // print('rawbody ${buff.runtimeType}');
    return buff.toString();
  }

  Map<String, dynamic> get queries {
    return jsObjectAsMap(getProperty(req, 'queries'));
  }

  @override
  String get url => req.url;

  @override
  String get path => getProperty(req, 'path');

  @override
  String get method => getProperty(req, 'method');

  dynamic get headers => getProperty(req, 'headers');

  @override
  String toString() {
    var map = <String, dynamic>{
      'queries': queries,
      'url': url,
      'path': path,
      'method': method,
      //'headers': headers
    };
    return map.toString();
  }
}

class FcHttpResponseJs implements FcHttpResponse {
  final _HttpResponseJs impl;

  FcHttpResponseJs(this.impl);

  @override
  void sendString(String text) {
    // var sendResponse =
    // callMethod(impl, 'send', [text]);
    impl.send(text);
  }

  void setStatusCode(int statusCode) {
    // to call first
    // var sendResponse =
    callMethod(impl, 'setStatusCode', [statusCode]);
  }

  void setHeader(String key, String value) {
    // to call first
    // var sendResponse =
    callMethod(impl, 'setHeader', [key, value]);
  }

  void setContentTypeJson() {
    setHeader('Content-Type', 'application/json');
  }
//response.setStatusCode(200);
//response.setHeader('content-type', 'application/json');
}
