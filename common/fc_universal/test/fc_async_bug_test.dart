import 'package:path/path.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:test/test.dart';

// Never name the handler 'handler'!
Future<void> handler(
  FcHttpRequest httpRequest,
  FcHttpResponse httpResp,
  FcHttpContext httpContext,
) async {
  try {
    await httpResp.sendString('1'); //jsonEncode(response));
  } catch (e) {
    await httpResp.sendString('2');
  }
}

Future<void> renamedHandler(
  FcHttpRequest httpRequest,
  FcHttpResponse httpResp,
  FcHttpContext httpContext,
) async {
  try {
    await httpResp.sendString('1'); //jsonEncode(response));
  } catch (e) {
    await httpResp.sendString('2');
  }
}

void main() {
  group('memory', () {
    late AliyunFunctionComputeUniversal functionCompute;
    setUp(() {
      functionCompute = AliyunFunctionComputeHttpUniversal(
        httpServerFactoryMemory,
      );
    });

    test('bug_async', () async {
      functionCompute.exportHttpHandler(handler);
      var server = await functionCompute.serve(port: 0);
      var uri = server.uri;
      var client = httpClientFactoryMemory.newClient();
      await httpClientRead(
        client,
        httpMethodGet,
        Uri.parse(url.join(uri.toString(), 'handler')),
      );
      //var map = jsonDecode(result) as Map;

      await server.close();
      client.close();
    }, skip: 'Never name a function \'handler\'');

    test('no_bug_async', () async {
      functionCompute.exportHttpHandler(renamedHandler);
      var server = await functionCompute.serve(port: 0);
      var uri = server.uri;
      var client = httpClientFactoryMemory.newClient();
      await httpClientRead(
        client,
        httpMethodGet,
        Uri.parse(url.join(uri.toString(), 'handler')),
      );
      //var map = jsonDecode(result) as Map;
      await server.close();
      client.close();
    });
  });
}
