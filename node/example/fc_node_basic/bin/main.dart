/*void main() {
  print('Hello');
}
*/
import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:tekartik_common_utils/json_utils.dart';
import 'package:tekartik_http/http.dart';

Future<void> main() async {
  aliyunFunctionComputeUniversal.exportHttpHandler((FcHttpRequest request,
      FcHttpResponse response, FcHttpContext httpContext) async {
    response.setStatusCode(201);
    response.setHeader(httpHeaderContentType, httpContentTypeJson);
    response.setHeader('x-test', 'x-value');
    var body = await request.getBodyString();
    var map = {
      'version': 3,
      'tag': 'v1',
      'method': request.method,
      'body': body,
      'path': request.path,
      'url': request.url,
      'headers': request.headers,
      'env': platform.environment,
    };
    await response.sendString(jsonPretty(map));
  });
  await aliyunFunctionComputeUniversal.serve(port: 4998);
}

// curl -i -H "x-value-in: my value in" -d 'my_body' http://localhost:4998/handler?test=1
