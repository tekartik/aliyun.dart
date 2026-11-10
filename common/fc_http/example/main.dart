// ignore_for_file: avoid_print

import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_http/fc_http.dart';
import 'package:tekartik_http/http_memory.dart';

Future<void> helloHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  response.setHeader(httpHeaderContentType, httpContentTypeText);
  await response.sendString('${request.method} ${request.path}');
}

Future<void> main() async {
  var functionCompute = AliyunFunctionComputeHttp(httpServerFactoryMemory);
  functionCompute.exportHttpHandler(helloHandler); // served at /handler
  var server = await functionCompute.serveHttp(port: 0);
  var client = httpClientFactoryMemory.newClient();
  try {
    var uri = httpServerGetUri(server).resolve('handler/sub');
    print(await httpClientRead(client, httpMethodGet, uri)); // GET /handler/sub
  } finally {
    client.close();
    await server.close();
  }
}
