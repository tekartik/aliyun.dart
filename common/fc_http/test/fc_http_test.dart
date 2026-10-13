import 'dart:convert';
import 'dart:typed_data';

import 'package:tekartik_aliyun_fc_http/src/function_compute_http.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_io/http_server_io.dart';
import 'package:test/test.dart';

void main() {
  group('memory', () {
    fcHttpTests(httpServerFactoryMemory, httpClientFactoryMemory, 'localhost');
  });
  group('io', () {
    fcHttpTests(httpServerFactoryIo, httpClientFactoryIo, '127.0.0.1');
  });
}

void fcHttpTests(
  HttpServerFactory serverFactory,
  HttpClientFactory clientFactory,
  String host,
) {
  group('fc_http', () {
    late AliyunFunctionComputeHttp functionCompute;
    setUp(() {
      functionCompute = AliyunFunctionComputeHttp(serverFactory);
    });

    test('basic', () async {
      functionCompute.exportHttpHandler((request, response, context) async {
        var body = await request.getBodyString();
        response.setHeader('content-type', 'application/json');
        expect(request.headers['Upper'], 'Value');
        expect(request.headers['upper'], 'Value');
        await response.sendString(
          jsonEncode({
            'method': request.method,
            'body': body,
            'path': request.path,
            'url': request.url,
            'headers': request.headers,
          }),
        );
      });
      var server = await functionCompute.serveHttp(port: 0);
      var url = 'http://$host:${server.port}';
      var client = clientFactory.newClient();
      var result = await httpClientRead(
        client,
        httpMethodGet,
        Uri.parse('$url/handler?t=1'),
        headers: {'hk': 'hv', 'Upper': 'Value'},
        body: 'body_data',
      );
      var map = jsonDecode(result) as Map;

      expect(map['method'], 'GET');
      expect(map['body'], 'body_data');
      expect(map['path'], '/handler');
      expect(map['url'], endsWith('/handler?t=1'));
      await server.close(force: true);
      client.close();
    });

    test('binary', () async {
      functionCompute.exportHttpHandler((request, response, context) async {
        await response.sendBytes(Uint8List.fromList(utf8.encode('test')));
      });
      var server = await functionCompute.serveHttp(port: 0);
      var url = 'http://$host:${server.port}';
      var client = clientFactory.newClient();
      var result = await httpClientRead(
        client,
        httpMethodGet,
        Uri.parse('$url/handler'),
      );
      expect(result, 'test');
      await server.close(force: true);
      client.close();
    });

    test('body read twice', () async {
      functionCompute.exportHttpHandler((request, response, context) async {
        var text = await request.getBodyString();
        var bytes = await request.getBodyBytes();
        await response.sendString('$text ${bytes.length}');
      });
      var server = await functionCompute.serveHttp(port: 0);
      var client = clientFactory.newClient();
      var result = await httpClientRead(
        client,
        httpMethodPost,
        Uri.parse('http://$host:${server.port}/handler'),
        body: 'body',
      );
      expect(result, 'body 4');
      await server.close(force: true);
      client.close();
    });

    test('not found and errors', () async {
      functionCompute.exportHttpHandler((request, response, context) async {
        throw StateError('handler failure');
      });
      var server = await functionCompute.serveHttp(port: 0);
      var url = 'http://$host:${server.port}';
      var client = clientFactory.newClient();
      for (var path in ['/', '/other']) {
        var response = await httpClientSend(
          client,
          httpMethodGet,
          Uri.parse('$url$path'),
        );
        expect(response.statusCode, httpStatusCodeNotFound, reason: path);
      }
      var response = await httpClientSend(
        client,
        httpMethodGet,
        Uri.parse('$url/handler'),
      );
      expect(response.statusCode, httpStatusCodeInternalServerError);
      await server.close(force: true);
      client.close();
    });
  });
}
