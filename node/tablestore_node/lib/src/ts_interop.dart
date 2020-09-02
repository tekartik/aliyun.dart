@JS()
library tekartik_aliyun_tablestore_node.ts_interop;

import 'dart:js_util';

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

import 'import.dart';

/// A structure for options provided to Firebase.
@JS()
@anonymous
class _TsClientOptionsJs {
  external String get accessKeyId;

  external set accessKeyId(String s);

  external String get secretAccessKey;

  external set endpoint(String s);

  external String get endpoint;

  external set instancename(String s);

  external String get instancename;

  external factory _TsClientOptionsJs(
      {String accessKeyId,
      String secretAccessKey,
      String endpoint,
      String instancename,
      String storageBucket,
      String messagingSenderId});
}

@JS()
@anonymous
abstract class _TablestoreJs {
  /// Reference to constructor Client.
  external dynamic get Client;
}

@JS()
@anonymous
class _TsClientListTableParamsJs {}

class TableStoreNodeException implements Exception {
  final String message;

  TableStoreNodeException(this.message);

  @override
  String toString() => 'TableStoreNodeException($message)';
}

@JS()
@anonymous
class _TsClientJs {
  external void listTable(_TsClientListTableParamsJs params, Function callback);
}

@JS()
@anonymous
class _TsTableJs {}

class TsTableNode implements TsTable {
  final _TsTableJs native;

  TsTableNode(this.native);
}

@JS()
@anonymous
abstract class _TsClientListTableResponseJs {
  List<String> get tableNames;
}

class TsClientNode with TsClientMixin implements TsClient {
  final _TsClientJs native;

  TsClientNode(this.native);

  void _handleError(Completer completer, dynamic err) {
    if (!completer.isCompleted) {
      if (err is TableStoreNodeException) {
        completer.completeError(err);
      } else {
        completer.completeError(TableStoreNodeException(err.toString()));
      }
    }
  }

  void _handleSuccess<T>(Completer<T> completer, T data) {
    if (!completer.isCompleted) {
      completer.complete(data);
    }
  }

  @override
  Future<List<String>> listTableNames() {
    var completer = Completer<List<String>>();
    try {
      native.listTable(_TsClientListTableParamsJs(), allowInterop((err, data) {
        if (err != null) {
          _handleError(completer, err);
        } else {
          var response = data as _TsClientListTableResponseJs;
          // print(jsObjectToDebugString(response));
          // {tableNames: [Exp1, Exp2], RequestId: 0005ae3d-8b60-c9d8-a4c1-720b0589c481}

          _handleSuccess(completer, List<String>.from(response.tableNames));
        }
      }));
    } catch (e) {
      _handleError(completer, e);
    }
    return completer.future;
  }

  @override
  String toString() {
    return 'TsClientNode()';
  }
}

class TablestoreNode with TablestoreMixin implements Tablestore {
  @override
  TsClient client({TsClientOptions options}) {
    var nativeClient = callConstructor(_tablestoreJs.Client, [
      _TsClientOptionsJs(
          accessKeyId: options.accessKeyId,
          secretAccessKey: options.secretAccessKey,
          endpoint: options.endpoint,
          instancename: options.instanceName)
    ]);
    if (nativeClient == null) {
      return null;
    }

    return TsClientNode(nativeClient);
  }

  @override
  String toString() {
    return 'TablestoreNode()';
  }
}

final _tablestoreJs = require('tablestore') as _TablestoreJs;
/*

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


// Example
var getRawBody = require('raw-body')
getRawBody(request, function(err, data){
  var body = data
})



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

  Future<String> getBodyString() async {
    var buff = await _getRawBody(encoding: true);
    // print('rawbody ${buff.runtimeType}');
    return buff.toString();
  }

  Map<String, dynamic> get queries {
    return jsObjectAsMap(getProperty(req, 'queries'));
  }

  String get url => req.url;

  String get path => getProperty(req, 'path');

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
*/
