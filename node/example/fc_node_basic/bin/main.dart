/*void main() {
  print('Hello');
}
*/
import 'dart:convert';

import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_http/http.dart';

Future<void> main() async {
  aliyunFunctionCompute.exportHttpHandler((FcHttpRequest httpRequest,
      FcHttpResponse httpResp, FcHttpContext httpContext) async {
    httpResp.setStatusCode(300);
    httpResp.setHeader(httpHeaderContentType, httpContentTypeJson);
    // First
    httpResp.setHeader('x-test', 'x-value');

    var map = {
      'version': 1,
      'tag': 'v1',
    };
    await httpResp.sendString(jsonEncode(map));
  });
  await aliyunFunctionCompute.serve(port: 0);
}
