import 'dart:async';

import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_http/src/fc_context_http.dart';
import 'package:tekartik_aliyun_fc_http/src/fc_request_http.dart';
import 'package:tekartik_aliyun_fc_http/src/fc_response_http.dart';
import 'package:tekartik_http/http_memory.dart';

class _HandlerInfo {
  final String name;
  final FcHttpHandler handler;

  _HandlerInfo(this.name, this.handler);
}

class AliyunFunctionComputeHttp implements AliyunFunctionCompute {
  final HttpServerFactory httpServerFactory;
  final _functions = <String, _HandlerInfo>{};
  static const defaultPort = 4998;

  AliyunFunctionComputeHttp(this.httpServerFactory);

  @override
  void exportHttpHandler(FcHttpHandler handler, {String name = 'handler'}) {
    assert(_functions.isEmpty, 'Handler already exported');
    _functions[name] = _HandlerInfo(name, handler);
  }

  Future<HttpServer> serveHttp({required int port}) async {
    assert(_functions.isNotEmpty, 'No handler exported');

    var requestServer = await httpServerFactory.bind(
      InternetAddress.anyIPv4,
      port,
    );
    var serverPort = requestServer.port;
    for (final info in _functions.values) {
      print('http://localhost:$serverPort/${info.name}');
    }
    unawaited(
      Future.sync(() async {
        await for (HttpRequest request in requestServer) {
          var uri = request.uri;
          // /test
          var functionKey = uri.pathSegments.first;
          var function = _functions[functionKey];
          if (function == null) {
            request.response.statusCode = httpStatusCodeNotFound;
            request.response.writeln('not found');
          } else {
            var fcHttpRequestHttp = FcHttpRequestHttp(request);
            var fcHttpResponseHttp = FcHttpResponseHttp(request);
            var fcHttpContextHttp = FcHttpContextHttp(request);
            function.handler(
              fcHttpRequestHttp,
              fcHttpResponseHttp,
              fcHttpContextHttp,
            );
          }
        }
      }),
    );
    return requestServer;
  }
}

final aliyunFunctionComputeMemory = AliyunFunctionComputeHttp(
  httpServerFactoryMemory,
);
