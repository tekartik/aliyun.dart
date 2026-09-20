---
name: tekartik-aliyun-fc-handler
description: >-
  Use when writing an Aliyun Function Compute HTTP handler in Dart against the
  runtime-neutral tekartik_aliyun_fc API: FcHttpHandler, FcHttpRequest (path,
  url, method, headers, getBodyString, getBodyBytes), FcHttpResponse
  (setStatusCode, setHeader, sendString, sendBytes), FcHttpContext,
  AliyunFunctionCompute.exportHttpHandler, the
  package:tekartik_aliyun_fc/fc.dart import, unit testing a handler with
  hand-written fakes, and picking the runtime package (fc_http for a local
  http server, fc_node for nodejs, fc_universal for both).
---

# Function Compute HTTP handler API (tekartik_aliyun_fc)

`tekartik_aliyun_fc` is the abstract binding for Aliyun Function Compute HTTP
triggers: a request, a response, a context and a factory that exports one
handler. It contains no runtime. `tekartik_aliyun_fc_http` (local `tekartik_http`
server, memory or io), `tekartik_aliyun_fc_node` (the real nodejs runtime) and
`tekartik_aliyun_fc_universal` (picks one at compile time) implement it; write
the handler code against this package only.

## Guidelines

* Dependency (git, not on pub.dev; the repo is a pub workspace, `path` is
  required):
  ```yaml
  dependencies:
    tekartik_aliyun_fc:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/fc
  ```
* Import `package:tekartik_aliyun_fc/fc.dart` (it re-exports `fc_api.dart`,
  the only public library). Never import `lib/src/`.
* A handler is an `FcHttpHandler`:
  `dynamic Function(FcHttpRequest request, FcHttpResponse response, FcHttpContext context)`.
  Declare it `Future<void> ... async`. The runtimes call it without awaiting
  and do not catch its errors: wrap the body in `try`/`catch` and always
  send an answer, otherwise the caller waits forever.
* Register it once with
  `AliyunFunctionCompute.exportHttpHandler(handler, name: 'handler')`.
  `name` (default `'handler'`) is the exported function name:
  `Handler: index.handler` in the Function Compute template, the first url
  path segment on the local http server. Each implementation accepts one
  export per instance ("Can be called only once").
* Do not name the top-level Dart function `handler` (the default export
  name): the node build misbehaves, see `test/fc_async_bug_test.dart` in
  `tekartik_aliyun_fc_universal`. Use `apiHandler`, `echoHandler`...
* `FcHttpRequest`: `method` (`'GET'`, `'POST'`...), `path` (the url path,
  `/handler/sub` locally, the part after the function url on Aliyun), `url`
  (the url string with its query on the http runtime), `headers` (read-only
  `Map<String, String>`, keys stored lower case, lookup is case insensitive,
  writing throws `StateError('read-only')`), `getBodyString()` (utf-8) and
  `getBodyBytes()` (`Uint8List`); the body is read once and cached, calling
  both is fine. Query parameters are not exposed separately: parse
  `Uri.parse(request.url).queryParameters`.
* `FcHttpResponse`: call `setStatusCode(int)` and `setHeader(name, value)`
  first, then exactly one of `sendString(text)` or `sendBytes(bytes)` and
  `await` it; sending closes the response, nothing can be set afterwards.
* `FcHttpContext` carries nothing at this level (the node runtime adds the
  credentials). Accept it in the signature, ignore it in shared code.
* Aliyun limits (HTTP trigger documentation quoted in `fc_api.dart`):
  headers 4 KB and body 6 MB in both directions; user set response headers
  such as `content-length`, `content-encoding`, `date`, `server` and any
  `x-fc-*` are ignored.
* `FcHttp`, `FcHttpFunction` and `FcRequestHandler` are unused leftovers of
  an older design; ignore them.
* Testing: implement `FcHttpRequest`, `FcHttpResponse` and `FcHttpContext`
  with small fakes (example below) to unit test the logic without a server,
  or run the handler on `tekartik_aliyun_fc_http` with the memory http
  factory (`tekartik-aliyun-fc-http-setup` skill). `FcHttpRequestHeaders`
  (`lib/src/mixin/fc_http_request_headers.dart`, an implementation import)
  wraps a lower-cased map for the runtimes; it is not public API.

## Examples

### JSON echo handler, registered on any implementation

```dart
import 'dart:convert';

import 'package:tekartik_aliyun_fc/fc.dart';

/// Answers a json description of the request. Never name it `handler`.
Future<void> echoHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  try {
    var body = await request.getBodyString();
    response.setStatusCode(200);
    response.setHeader('Content-Type', 'application/json');
    await response.sendString(
      jsonEncode({
        'method': request.method,
        'path': request.path,
        'url': request.url,
        'query': Uri.parse(request.url).queryParameters,
        'headers': request.headers, // lower case keys
        'body': body,
      }),
    );
  } catch (e) {
    response.setStatusCode(500);
    await response.sendString('error: $e');
  }
}

/// Called once from main with the runtime of the platform
/// (aliyunFunctionComputeUniversal, an AliyunFunctionComputeHttp...).
void registerHandlers(AliyunFunctionCompute functionCompute) {
  functionCompute.exportHttpHandler(echoHandler);
}
```

### Route on the last path segment, binary in and out

```dart
import 'package:tekartik_aliyun_fc/fc.dart';

Future<void> apiHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  var command = request.path.split('/').last;
  switch (command) {
    case 'bodyBytes':
      // Echo the body untouched.
      var bytes = await request.getBodyBytes();
      response.setStatusCode(200);
      response.setHeader('Content-Type', 'application/octet-stream');
      await response.sendBytes(bytes);
    case 'ping':
      response.setStatusCode(200);
      response.setHeader('Content-Type', 'text/plain');
      await response.sendString('pong');
    default:
      response.setStatusCode(404);
      await response.sendString('unknown command $command');
  }
}
```

### Unit test with fakes, no server

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:test/test.dart';

class FakeRequest implements FcHttpRequest {
  @override
  final String method;
  @override
  final String path;
  @override
  final Map<String, String> headers;
  final String body;

  FakeRequest({
    this.method = 'GET',
    this.path = '/handler',
    this.headers = const {},
    this.body = '',
  });

  @override
  String get url => 'http://localhost$path';

  @override
  Future<Uint8List> getBodyBytes() async =>
      Uint8List.fromList(utf8.encode(body));

  @override
  Future<String> getBodyString() async => body;
}

class FakeResponse implements FcHttpResponse {
  int? statusCode;
  final headers = <String, String>{};
  Object? sent;

  @override
  void setStatusCode(int statusCode) => this.statusCode = statusCode;

  @override
  void setHeader(String name, String value) => headers[name] = value;

  @override
  Future<void> sendString(String text) async => sent = text;

  @override
  Future<void> sendBytes(Uint8List bytes) async => sent = bytes;
}

class FakeContext implements FcHttpContext {}

Future<void> helloHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  var name = (await request.getBodyString()).trim();
  response.setStatusCode(200);
  response.setHeader('Content-Type', 'text/plain');
  await response.sendString('hello ${name.isEmpty ? 'world' : name}');
}

void main() {
  test('hello', () async {
    var response = FakeResponse();
    await helloHandler(
      FakeRequest(method: 'POST', body: 'alex'),
      response,
      FakeContext(),
    );
    expect(response.statusCode, 200);
    expect(response.headers['Content-Type'], 'text/plain');
    expect(response.sent, 'hello alex');
  });
}
```

## Common mistakes

* Naming the Dart function `handler`.
* Calling `exportHttpHandler` twice on the same instance.
* Setting a header or the status code after `sendString`/`sendBytes`.
* Letting an exception escape the handler: nothing is sent, the client hangs.
* Writing to `request.headers` or looking for query parameters in `path`.
