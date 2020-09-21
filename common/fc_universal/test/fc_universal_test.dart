import 'dart:convert';

import 'package:path/path.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http.dart'
    hide httpClientFactoryMemory, httpServerFactoryMemory;
import 'package:test/test.dart';

void main() {
  group('memory', () {
    AliyunFunctionComputeUniversal functionCompute;
    setUp(() {
      functionCompute = aliyunFunctionComputeUniversalMemory;
    });

    test('basic', () async {
      functionCompute.exportHttpHandler((request, response, context) async {
        var body = await request.getBodyString();
        response.setStatusCode(201);
        response.setHeader('content-type', 'application/json');
        response.setHeader('x-response', 'test2');
        await response.sendString(jsonEncode({
          'method': request.method,
          'body': body,
          'path': request.path,
          'url': request.url,
          'headers': request.headers
        }));
      });
      var server = await functionCompute.serve(port: 0);
      var uri = server.uri;
      var client = httpClientFactoryMemory.newClient();
      var result = await httpClientRead(
          client, httpMethodGet, '${url.join(uri.toString(), 'handler?t=1')}',
          headers: {'hk': 'hv'}, body: 'body_data');
      var map = jsonDecode(result) as Map;

      expect(map['method'], 'GET');
      expect(map['body'], 'body_data');
      expect(map['path'], '/handler');
      expect(map['url'], endsWith('/handler?t=1'));

      var response = await httpClientSend(
          client, httpMethodGet, '${url.join(uri.toString(), 'handler?t=1')}',
          headers: {'hk': 'hv'}, body: 'body_data');
      expect(response.statusCode, 201);
      expect(response.headers['x-response'], 'test2');
      await server.close();
      client.close();
    });
  });
}
