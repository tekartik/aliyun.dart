// ignore_for_file: avoid_print

import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_http/http_memory.dart';

/// Never name the Dart function `handler` (breaks the node build).
Future<void> helloHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  response.setStatusCode(200);
  response.setHeader(httpHeaderContentType, httpContentTypeText);
  await response.sendString('${request.method} ${request.path}');
}

/// The handler on a memory server, called once.
///
/// In a deployed `bin/main.dart`, use `aliyunFunctionComputeUniversal`
/// instead: a local server on the Dart VM, the Function Compute function on
/// nodejs.
Future<void> main() async {
  var functionCompute = newAliyunFunctionComputeUniversalMemory();
  functionCompute.exportHttpHandler(helloHandler); // served at /handler
  var server = await functionCompute.serve(port: 0);
  var client = httpClientFactoryMemory.newClient();
  try {
    var uri = server.uri!.resolve('handler/sub');
    print(await httpClientRead(client, httpMethodGet, uri)); // GET /handler/sub
  } finally {
    client.close();
    await server.close();
  }
}
