---
name: tekartik-aliyun-fc-http-setup
description: >-
  Use when running or testing an Aliyun Function Compute HTTP handler locally
  on a tekartik_http server with tekartik_aliyun_fc_http:
  AliyunFunctionComputeHttp(httpServerFactory), exportHttpHandler,
  serveHttp(port:), defaultPort (4998), aliyunFunctionComputeMemory with
  httpServerFactoryMemory and httpClientFactoryMemory, a dart:io dev server on
  httpServerFactoryIo, the package:tekartik_aliyun_fc_http/fc_http.dart import,
  the http://localhost:<port>/<handler name> url layout and calling the
  function with httpClientRead, httpClientReadBytes or httpClientSend.
---

# Local http runtime for Function Compute handlers (tekartik_aliyun_fc_http)

`tekartik_aliyun_fc_http` runs an `FcHttpHandler` (from `tekartik_aliyun_fc`)
behind a `tekartik_http` `HttpServer`: in memory for tests, on `dart:io` for a
local dev server. Nothing here talks to Aliyun; it mimics the HTTP trigger so
the same handler code is exercised before being deployed with
`tekartik_aliyun_fc_node` (or through `tekartik_aliyun_fc_universal`, which
wraps this package on the VM).

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_aliyun_fc_http:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/fc_http
    tekartik_aliyun_fc:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/fc
    tekartik_http:
      git:
        url: https://github.com/tekartik/http.dart
        path: http
  ```
  Add `tekartik_http_io` (same repo, `path: http_io`) for the io server.
* Imports: `package:tekartik_aliyun_fc_http/fc_http.dart` exports
  `AliyunFunctionComputeHttp` and `aliyunFunctionComputeMemory`. Handler
  types come from `package:tekartik_aliyun_fc/fc.dart`; the memory factories,
  client helpers (`httpClientRead`, `httpClientReadBytes`, `httpClientSend`),
  `httpServerGetUri` and the `httpMethod*`/`httpHeader*`/`httpContentType*`
  constants from `package:tekartik_http/http_memory.dart`;
  `httpServerFactoryIo` from `package:tekartik_http_io/http_server_io.dart`
  (which does not re-export the constants, import `tekartik_http/http.dart`
  next to it). `fc_http_io.dart` only re-exports `AliyunFunctionComputeHttp`:
  there is no exported io singleton, build one with `httpServerFactoryIo`.
* Construct `AliyunFunctionComputeHttp(httpServerFactory)` (any
  `HttpServerFactory`), call `exportHttpHandler(handler, name: 'handler')`
  exactly once (a second call fails an assert), then
  `var server = await fc.serveHttp(port: port)`. It binds
  `InternetAddress.anyIPv4`; `port` `0` picks a free port,
  `AliyunFunctionComputeHttp.defaultPort` is `4998`. The returned
  `tekartik_http` `HttpServer` gives `server.port`,
  `httpServerGetUri(server)` (`http://localhost:<port>/`, `http://_memory:<n>/`
  in memory) and `server.close(force: true)`. `serveHttp` prints
  `http://localhost:<port>/<name>` for the exported handler.
* Routing: the first path segment must be the exported `name`
  (`/handler`, `/handler/anything?x=1`). Any other first segment gets a 404
  status but the response is never closed (the client waits): only call
  exported names, route sub commands inside the handler on `request.path`.
* Request mapping: `request.path` is the full path (`/handler/anything`),
  `request.url` the absolute url with query, `request.headers` lower-cased
  (multi-valued headers joined with `,`), `getBodyString`/`getBodyBytes`
  read the whole body (GET or POST). `sendString`/`sendBytes` write and
  close the response; `setStatusCode`/`setHeader` must come before. The
  handler is invoked without being awaited and its errors are not caught:
  wrap the body in `try`/`catch` and answer an error status.
* `aliyunFunctionComputeMemory` is a shared instance on
  `httpServerFactoryMemory`; since an instance accepts a single export,
  create a fresh `AliyunFunctionComputeHttp(httpServerFactoryMemory)` per
  test in `setUp`.
* Call the served function with a `tekartik_http` client:
  `httpClientFactoryMemory.newClient()` for a memory server (a memory client
  only reaches memory servers), `httpClientFactoryIo.newClient()` or `curl`
  for io. `httpClientRead(client, method, uri, headers:, body:)` returns the
  body text and throws on a non 2xx status, `httpClientReadBytes` the bytes,
  `httpClientSend` an `HttpClientResponse` with `statusCode`, `headers` and
  `body`. Build urls with `httpServerGetUri(server).resolve('handler?x=1')`.
* Run tests with `dart test` (VM); no node build is involved here.

## Examples

### Dev server on dart:io

```dart
import 'dart:convert';

import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_http/fc_http.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_io/http_server_io.dart';

Future<void> echoHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  try {
    var body = await request.getBodyString();
    response.setStatusCode(httpStatusCodeOk);
    response.setHeader(httpHeaderContentType, httpContentTypeJson);
    await response.sendString(
      jsonEncode({
        'method': request.method,
        'path': request.path,
        'headers': request.headers,
        'body': body,
      }),
    );
  } catch (e) {
    response.setStatusCode(httpStatusCodeInternalServerError);
    await response.sendString('error: $e');
  }
}

Future<void> main() async {
  var fc = AliyunFunctionComputeHttp(httpServerFactoryIo);
  fc.exportHttpHandler(echoHandler);
  // Prints http://localhost:4998/handler
  var server = await fc.serveHttp(port: AliyunFunctionComputeHttp.defaultPort);
  print('serving ${httpServerGetUri(server)}');
  // curl -i -H 'x-in: value' -d 'my_body' 'http://localhost:4998/handler?test=1'
}
```

### Test on the memory server

```dart
import 'dart:convert';

import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_http/fc_http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:test/test.dart';

Future<void> echoHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  var body = await request.getBodyString();
  response.setStatusCode(201);
  response.setHeader(httpHeaderContentType, httpContentTypeJson);
  response.setHeader('x-response', 'test2');
  await response.sendString(
    jsonEncode({
      'method': request.method,
      'path': request.path,
      'url': request.url,
      'headers': request.headers,
      'body': body,
    }),
  );
}

void main() {
  late AliyunFunctionComputeHttp fc;
  setUp(() {
    // One instance per test: a single export is allowed per instance.
    fc = AliyunFunctionComputeHttp(httpServerFactoryMemory);
  });

  test('echo', () async {
    fc.exportHttpHandler(echoHandler);
    var server = await fc.serveHttp(port: 0);
    var client = httpClientFactoryMemory.newClient();
    try {
      var uri = httpServerGetUri(server).resolve('handler/sub?t=1');
      var text = await httpClientRead(
        client,
        httpMethodPost,
        uri,
        headers: {'X-Custom': 'value'},
        body: 'body_data',
      );
      var map = jsonDecode(text) as Map;
      expect(map['method'], 'POST');
      expect(map['path'], '/handler/sub');
      expect(map['url'], endsWith('/handler/sub?t=1'));
      expect(map['body'], 'body_data');
      expect((map['headers'] as Map)['x-custom'], 'value');

      var response = await httpClientSend(client, httpMethodGet, uri);
      expect(response.statusCode, 201);
      expect(response.headers['x-response'], 'test2');
    } finally {
      client.close();
      await server.close(force: true);
    }
  });
}
```

### Binary round trip with a named export

```dart
import 'dart:typed_data';

import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_http/fc_http.dart';
import 'package:tekartik_http/http_memory.dart';

Future<void> reverseHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  var bytes = await request.getBodyBytes();
  response.setStatusCode(httpStatusCodeOk);
  response.setHeader(httpHeaderContentType, httpContentTypeBytes);
  await response.sendBytes(Uint8List.fromList(bytes.reversed.toList()));
}

/// Serves `reverseHandler` as /reverse, posts [input], returns the answer.
Future<Uint8List> roundTrip(Uint8List input) async {
  var fc = AliyunFunctionComputeHttp(httpServerFactoryMemory);
  fc.exportHttpHandler(reverseHandler, name: 'reverse');
  var server = await fc.serveHttp(port: 0);
  var client = httpClientFactoryMemory.newClient();
  try {
    return await httpClientReadBytes(
      client,
      httpMethodPost,
      httpServerGetUri(server).resolve('reverse'),
      body: input,
    );
  } finally {
    client.close();
    await server.close(force: true);
  }
}

Future<void> main() async {
  print(await roundTrip(Uint8List.fromList([1, 2, 3]))); // [3, 2, 1]
}
```

## Common mistakes

* Expecting `aliyunFunctionComputeIo` to exist: build
  `AliyunFunctionComputeHttp(httpServerFactoryIo)` yourself.
* Reusing `aliyunFunctionComputeMemory` across tests (second export asserts).
* Requesting a path whose first segment is not the exported name: the
  client hangs on an unclosed 404.
* Forgetting `server.close(force: true)` and `client.close()` in tests.
* Using a memory client against an io server or the reverse.
