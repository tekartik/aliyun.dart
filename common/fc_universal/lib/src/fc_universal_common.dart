import 'package:tekartik_aliyun_fc_http/fc_http.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http_server.dart';

export 'package:tekartik_aliyun_fc/fc_api.dart';
export 'package:tekartik_aliyun_fc_http/src/function_compute_http.dart';

abstract class FcServer {
  Uri get uri;
  Future<void> close();
}

abstract class AliyunFunctionComputeUniversal extends AliyunFunctionCompute {
  /// No effect on node
  Future<FcServer> serve({int port});
}

class FcServerHttp implements FcServer {
  final HttpServer httpServer;

  FcServerHttp(this.httpServer);

  @override
  Future<void> close() async {
    await httpServer.close(force: true);
  }

  @override
  Uri get uri => httpServerGetUri(httpServer);
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

AliyunFunctionComputeUniversal newAliyunFunctionComputeUniversalMemory() =>
    AliyunFunctionComputeHttpUniversal(httpServerFactoryMemory);
