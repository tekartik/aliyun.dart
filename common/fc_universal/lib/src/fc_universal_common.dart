import 'package:tekartik_aliyun_fc_http/fc_http.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_http/http_memory.dart';

export 'package:tekartik_aliyun_fc/fc_api.dart';
export 'package:tekartik_aliyun_fc_http/src/function_compute_http.dart';

/// The server returned by [AliyunFunctionComputeUniversal.serve].
abstract class FcServer {
  /// The server root (`http://localhost:<port>/`), the handler is at
  /// `handler` below it; null on nodejs (no local server).
  Uri? get uri;

  /// Stops the server (no-op on nodejs).
  Future<void> close();
}

/// A Function Compute runtime that can also serve its handler locally.
abstract class AliyunFunctionComputeUniversal extends AliyunFunctionCompute {
  /// Serves the exported handler on [port] (`0`: a free port): required on
  /// the Dart VM and in memory, no effect on nodejs.
  Future<FcServer> serve({int? port});
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
  AliyunFunctionComputeHttpUniversal(super.httpServerFactory);

  @override
  Future<FcServer> serve({int? port}) async {
    var httpServer = await serveHttp(port: port!);
    return FcServerHttp(httpServer);
  }
}

/// The shared memory instance (one handler export): prefer
/// [newAliyunFunctionComputeUniversalMemory] in tests.
final AliyunFunctionComputeUniversal aliyunFunctionComputeUniversalMemory =
    AliyunFunctionComputeHttpUniversal(httpServerFactoryMemory);

/// A new memory instance (every platform), for a test.
AliyunFunctionComputeUniversal newAliyunFunctionComputeUniversalMemory() =>
    AliyunFunctionComputeHttpUniversal(httpServerFactoryMemory);
