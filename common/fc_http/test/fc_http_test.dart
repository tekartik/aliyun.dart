import 'dart:convert';

import 'package:tekartik_aliyun_fc_http/src/function_compute_http.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http.dart'
    hide httpClientFactoryMemory, httpServerFactoryMemory;
import 'package:test/test.dart';

void main() {
  group('memory', () {
    AliyunFunctionComputeHttp functionCompute;
    setUp(() {
      functionCompute = AliyunFunctionComputeHttp(httpServerFactoryMemory);
    });

    test('basic', () async {
      functionCompute.exportHttpHandler((request, response, context) async {
        var body = await request.getBodyString();
        response.setHeader('content-type', 'application/json');
        expect(request.headers['Upper'], 'Value');
        expect(request.headers['upper'], 'Value');
        await response.sendString(jsonEncode({
          'method': request.method,
          'body': body,
          'path': request.path,
          'url': request.url,
          'headers': request.headers
        }));
      });
      var server = await functionCompute.serveHttp(port: 0);
      var url = 'http://localhost:${server.port}';
      var client = httpClientFactoryMemory.newClient();
      var result = await httpClientRead(
          client, httpMethodGet, '$url/handler?t=1',
          headers: {'hk': 'hv', 'Upper': 'Value'}, body: 'body_data');
      var map = jsonDecode(result) as Map;

      expect(map['method'], 'GET');
      expect(map['body'], 'body_data');
      expect(map['path'], '/handler');
      expect(map['url'], endsWith('/handler?t=1'));
      await server.close(force: true);
      client.close();
    });
  });
}
