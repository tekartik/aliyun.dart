@JS()
library tekartik_aliyun_fc_node.fc_interop;

import 'dart:js_util';
import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_aliyun_fc/src/mixin/fc_http_request_headers.dart'; // ignore: implementation_imports
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_js_utils/js_utils.dart';

@JS()
@anonymous
class HttpResponseJs {
  external void send(dynamic /*String|Uint8List*/ body);
}

@JS()
@anonymous
class HttpReqJs {
  external String get url;
}

@JS()
@anonymous
class HttpContextJs {
  external Map<String, dynamic> get credentials;
}

@JS('Buffer')
class Buffer {
  external static Buffer from(Uint8List bytes);
}

typedef _GetBodyFn = dynamic Function(dynamic req, [dynamic option]);

/// https://www.npmjs.com/package/raw-body
var _getRawBodyFn = require('raw-body') as _GetBodyFn?;

/*
// Example
var getRawBody = require('raw-body')
getRawBody(request, function(err, data){
  var body = data
})

 */

// ["requestId","credentials","function","service","region","accountId","logger","retryCount"]
class FcHttpContextNode implements FcHttpContext {
  final HttpContextJs native;

  FcHttpContextNode(this.native);

  Map<String, dynamic>? get credentials => jsObjectAsMap(native.credentials);

  @override
  String toString() {
    var map = <String, dynamic>{
      'credentials': credentials,
    };
    return map.toString();
  }
}

// ["_events","_eventsCount","_maxListeners","method","clientIP","url","path","queries","headers","getHeader"
class FcHttpRequestNode implements FcHttpRequest {
  final HttpReqJs req;
  Future? _rawBody;

  FcHttpRequestNode(this.req);

  Future getRawBody() {
    return _rawBody ??= promiseToFuture(_getRawBodyFn!(req) as Object);
  }

  Future _getRawBody({bool? encoding}) {
    return _rawBody ??= promiseToFuture(
        _getRawBodyFn!(req, jsify({'encoding': encoding})) as Object);
  }

  @override
  Future<String> getBodyString() async {
    var buff = await _getRawBody(encoding: true);
    // print('rawbody ${buff.runtimeType}');
    return buff.toString();
  }

  @override
  Future<Uint8List> getBodyBytes() async {
    var buff = await _getRawBody();
    // devPrint('rawbody ${buff.runtimeType}');
    return buff as Uint8List;
  }

  Map<String, dynamic>? get queries {
    return jsObjectAsMap(getProperty(req, 'queries'));
  }

  @override
  String get url => req.url;

  @override
  String get path => getProperty(req, 'path') as String;

  @override
  String get method => getProperty(req, 'method') as String;

  FcHttpRequestHeaders? _headers;

  @override
  Map<String, String> get headers => _headers ??= () {
        var lowerCaseHaders = <String, String>{};
        // Need to loop through the keys
        var nativeHeaders = getProperty(req, 'headers');
        var keys = jsObjectKeys(nativeHeaders as Object);
        for (var key in keys) {
          lowerCaseHaders[key.toLowerCase()] =
              getProperty(nativeHeaders, key) as String;
        }
        return FcHttpRequestHeaders(lowerCaseHaders);
      }();

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

class FcHttpResponseNode implements FcHttpResponse {
  final HttpResponseJs impl;

  FcHttpResponseNode(this.impl);

  @override
  Future sendString(String text) async {
    // var sendResponse =
    // callMethod(impl, 'send', [text]);
    impl.send(text);
  }

  @override
  void setStatusCode(int statusCode) {
    // to call first
    // var sendResponse =
    callMethod(impl, 'setStatusCode', [statusCode]);
  }

  @override
  void setHeader(String key, String value) {
    // to call first
    // var sendResponse =
    callMethod(impl, 'setHeader', [key, value]);
  }

  void setContentTypeJson() {
    setHeader('Content-Type', 'application/json');
  }

  @override
  Future<void> sendBytes(Uint8List bytes) async {
    impl.send(Buffer.from(bytes));
  }
//response.setStatusCode(200);
//response.setHeader('content-type', 'application/json');
}
