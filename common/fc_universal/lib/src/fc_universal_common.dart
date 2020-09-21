import 'package:tekartik_aliyun_fc_http/fc_http.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http_server.dart' hide httpServerFactoryMemory;
import 'package:tekartik_http/src/http_server.dart'; // ignore: implementation_imports

export 'package:tekartik_aliyun_fc/fc_api.dart';
export 'package:tekartik_aliyun_fc_http/src/function_compute_http.dart';

class FcServerHttp implements FcServer {
  final HttpServer httpServer;

  FcServerHttp(this.httpServer);

  @override
  Future<void> close() async {
    await httpServer.close(force: true);
  }

  @override
  Uri get uri => httpServerGetDefaultUri(httpServer);
}

class AliyunFunctionComputeHttpUniversal extends AliyunFunctionComputeHttp
    implements AliyunFunctionComputeUniversal {
  AliyunFunctionComputeHttpUniversal(HttpServerFactory httpServerFactory)
      : super(httpServerFactory);

  @override
  Future<FcServer> serve({int port}) async {
    var httpServer = await serveHttp(port: port);
    if (httpServer != null) {
      return FcServerHttp(httpServer);
    }
    return null;
  }
}

final AliyunFunctionComputeUniversal aliyunFunctionComputeUniversalMemory =
    AliyunFunctionComputeHttpUniversal(httpServerFactoryMemory);
