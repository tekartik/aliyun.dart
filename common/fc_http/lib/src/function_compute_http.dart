// ignore_for_file: avoid_print

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

  /// Handle a single request, errors are reported as a 500 response.
  Future<void> _handleRequest(HttpRequest request) async {
    // /test
    var segments = request.uri.pathSegments;
    var function = segments.isEmpty ? null : _functions[segments.first];
    if (function == null) {
      request.response.statusCode = httpStatusCodeNotFound;
      request.response.writeln('not found');
      await request.response.close();
      return;
    }
    try {
      await function.handler(
        FcHttpRequestHttp(request),
        FcHttpResponseHttp(request),
        FcHttpContextHttp(request),
      );
    } catch (e, st) {
      print('handler ${function.name} error: $e');
      print(st);
      try {
        request.response.statusCode = httpStatusCodeInternalServerError;
        request.response.writeln('error');
        await request.response.close();
      } catch (_) {
        // Response already sent
      }
    }
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
          unawaited(_handleRequest(request));
        }
      }),
    );
    return requestServer;
  }
}

final aliyunFunctionComputeMemory = AliyunFunctionComputeHttp(
  httpServerFactoryMemory,
);
