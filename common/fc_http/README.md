# tekartik_aliyun_fc_http

Runs an Aliyun Function Compute HTTP handler (`tekartik_aliyun_fc`) on a
`tekartik_http` server: in memory for tests, on `dart:io` as a local
development server. The same handler is deployed on nodejs with
`tekartik_aliyun_fc_node` (`tekartik_aliyun_fc_universal` picks one).

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_aliyun_fc:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/fc
  tekartik_aliyun_fc_http:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/fc_http
  tekartik_http:
    git:
      url: https://github.com/tekartik/http.dart
      path: http
```

A handler served in memory and called
([example/main.dart](example/main.dart), `dart run example/main.dart`):

```dart
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
```

For a local server on `dart:io`, use
`AliyunFunctionComputeHttp(httpServerFactoryIo)` (`tekartik_http_io`) and
`serveHttp(port: AliyunFunctionComputeHttp.defaultPort)`:
`http://localhost:4998/handler`.

## Platforms

Memory: every platform. `httpServerFactoryIo`: Dart VM.

## Common pitfalls

* One handler per instance: `exportHttpHandler` is called once (name
  `handler` by default); create an instance per test.
* The first path segment is the handler name: `/handler`, `/handler/sub`.
  Another path gets a 404.
* `request.path` is the whole path (`/handler/sub`); `request.url` is
  `/handler/sub?x=1` on io and the absolute url in memory: read the query
  with `Uri.parse(request.url).queryParameters`.
* A handler error is answered 500 (and printed). A handler that returns
  without `sendString`/`sendBytes` leaves the client waiting.
* `serveHttp` binds every interface (`InternetAddress.anyIPv4`) and prints the
  handler url.

## Testing

```bash
dart test
```
