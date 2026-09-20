---
name: tekartik-aliyun-fc-universal-setup
description: >-
  Use when writing one Dart entry point for an Aliyun Function Compute HTTP
  function that runs both locally (dart:io http server) and on the nodejs
  runtime with tekartik_aliyun_fc_universal: aliyunFunctionComputeUniversal,
  AliyunFunctionComputeUniversal.exportHttpHandler and serve(port:), FcServer
  (uri, close), aliyunFunctionComputeUniversalMemory,
  newAliyunFunctionComputeUniversalMemory and AliyunFunctionComputeHttpUniversal
  for tests, the package:tekartik_aliyun_fc_universal/fc_universal.dart import,
  the build_runner dart2js node build (build.yaml, deploy/index.js,
  template.yml, fun deploy) and running the tests on vm and node.
---

# Universal Function Compute entry point (tekartik_aliyun_fc_universal)

`tekartik_aliyun_fc_universal` exposes one `aliyunFunctionComputeUniversal`
whose implementation is chosen at compile time: a `dart:io` http server
(`tekartik_aliyun_fc_http` on `httpServerFactoryIo`) when run by the Dart VM,
the real Function Compute binding (`tekartik_aliyun_fc_node`, which sets
`exports.<name>`) when compiled to javascript for node. The same
`bin/main.dart` serves `http://localhost:4998/handler` during development and
becomes `index.js` on Aliyun.

## Guidelines

* Dependency (git, not on pub.dev), plus the node tool chain described in the
  [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build):
  ```yaml
  dependencies:
    tekartik_aliyun_fc_universal:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: common/fc_universal
  dev_dependencies:
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.4.19'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
  ```
  Tests and tools using the memory http client (`httpClientFactoryMemory`,
  `httpClientRead`) also need `tekartik_http`
  (`https://github.com/tekartik/http.dart`, `path: http`).
* Import `package:tekartik_aliyun_fc_universal/fc_universal.dart`. It
  re-exports the `tekartik_aliyun_fc` API (`FcHttpRequest`, `FcHttpResponse`,
  `FcHttpContext`, `FcHttpHandler`, `AliyunFunctionCompute`) and adds
  `aliyunFunctionComputeUniversal`, `AliyunFunctionComputeUniversal`,
  `FcServer`, `aliyunFunctionComputeUniversalMemory`,
  `newAliyunFunctionComputeUniversalMemory()` and
  `AliyunFunctionComputeHttpUniversal`.
* `AliyunFunctionComputeUniversal` is `AliyunFunctionCompute` plus
  `Future<FcServer> serve({int? port})`. In `main`:
  `aliyunFunctionComputeUniversal.exportHttpHandler(myHandler)` once, then
  `await aliyunFunctionComputeUniversal.serve(port: 4998)`. On the VM `port`
  is mandatory (`0` picks a free port) and the `FcServer` has a non null
  `uri` (`http://localhost:<port>/`) and `close()`. On node `serve` does
  nothing: `uri` is `null`, `close()` is a no-op, the function was exported
  by `exportHttpHandler`. On any other platform (browser) the getter throws
  `UnsupportedError`.
* The `name:` of `exportHttpHandler` (default `'handler'`) is the first url
  path segment locally (`/handler`, `/handler/sub?x=1`) and the
  `Handler: index.<name>` of the Function Compute template. Never name the
  Dart function itself `handler` (recorded bug, `test/fc_async_bug_test.dart`).
  Locally, only call the exported name: another first segment gets a 404
  whose response is never closed.
* Keep `bin/main.dart` platform neutral: no `dart:io`, no `dart:js`; `print`
  and `Future.delayed` are fine. Set status and headers before the single
  `sendString`/`sendBytes`, `await` it, and catch your own errors: the
  runtime neither awaits the handler nor catches its exceptions.
* Tests: `AliyunFunctionComputeHttpUniversal(httpServerFactoryMemory)` or
  `newAliyunFunctionComputeUniversalMemory()` gives an isolated memory
  instance (one export each; `aliyunFunctionComputeUniversalMemory` is the
  shared one). `serve(port: 0)`, then call `server.uri!` with
  `httpClientFactoryMemory.newClient()` and `httpClientRead`/`httpClientSend`
  from `package:tekartik_http/http_memory.dart`; `close()` the server and
  the client. `dart_test.yaml` lists `platforms: [vm, node]`: `dart test`
  runs the VM side, `dart run tool/run_test_node.dart` (`nodeRunTest()` from
  `package:tekartik_build_node/build_node.dart`) compiles and runs the node
  side.
* Node build and deploy, as in `node/example/fc_node_basic` of the repo: a
  `build.yaml` compiling `bin/**` with `build_web_compilers|entrypoint`
  (`compiler: dart2js`), then
  `dart run build_runner build --output=build/ -- -p node` (or
  `afcNodeBuild()` from `package:tekartik_app_node_build/afc_build.dart`),
  copy `build/bin/main.dart.js` to `deploy/index.js`, and run `fun deploy`
  from `deploy/` with a `template.yml` declaring an
  `Aliyun::Serverless::Function` with `Handler: index.handler`,
  `Runtime: nodejs12`, `CodeUri: './'` and an `HTTP` event. Body reading on
  node goes through the `raw-body` module (`require('raw-body')`), available
  in the Function Compute nodejs runtime (the example deploys without a
  `package.json`).

## Examples

### bin/main.dart, one file for local run and deployment

```dart
import 'dart:convert';

import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';

/// Never name it `handler`.
Future<void> apiHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  var command = request.path.split('/').last;
  try {
    if (command == 'ping') {
      response.setStatusCode(200);
      response.setHeader('Content-Type', 'text/plain');
      await response.sendString('pong');
    } else if (command == 'bodyBytes') {
      response.setStatusCode(200);
      await response.sendBytes(await request.getBodyBytes());
    } else {
      var body = await request.getBodyString();
      response.setStatusCode(200);
      response.setHeader('Content-Type', 'application/json');
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
  } catch (e) {
    response.setStatusCode(500);
    await response.sendString('error: $e');
  }
}

Future<void> main() async {
  aliyunFunctionComputeUniversal.exportHttpHandler(apiHandler);
  // VM: listens on http://localhost:4998/handler
  //   curl -i -d 'my_body' 'http://localhost:4998/handler/ping'
  // Node: no-op, the function is already exported as exports.handler.
  var server = await aliyunFunctionComputeUniversal.serve(port: 4998);
  print('serving ${server.uri ?? 'on Function Compute'}');
}
```

### Test the handler on the memory implementation

```dart
import 'dart:convert';

import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:test/test.dart';

Future<void> jsonHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  var body = await request.getBodyString();
  response.setStatusCode(201);
  response.setHeader('content-type', 'application/json');
  response.setHeader('x-response', 'test2');
  await response.sendString(
    jsonEncode({'method': request.method, 'path': request.path, 'body': body}),
  );
}

void main() {
  late AliyunFunctionComputeUniversal fc;
  setUp(() {
    // Fresh instance: one export per instance.
    fc = newAliyunFunctionComputeUniversalMemory();
  });

  test('json', () async {
    fc.exportHttpHandler(jsonHandler);
    var server = await fc.serve(port: 0);
    var client = httpClientFactoryMemory.newClient();
    try {
      var uri = server.uri!.resolve('handler?t=1');
      var text = await httpClientRead(
        client,
        httpMethodGet,
        uri,
        headers: {'hk': 'hv'},
        body: 'body_data',
      );
      var map = jsonDecode(text) as Map;
      expect(map['method'], 'GET');
      expect(map['path'], '/handler');
      expect(map['body'], 'body_data');

      var response = await httpClientSend(client, httpMethodGet, uri);
      expect(response.statusCode, 201);
      expect(response.headers['x-response'], 'test2');
    } finally {
      client.close();
      await server.close();
    }
  });
}
```

### Same suite on an explicit http server factory

```dart
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:test/test.dart';

void defineTests(AliyunFunctionComputeUniversal Function() newFc) {
  test('serve and close', () async {
    var fc = newFc();
    fc.exportHttpHandler((request, response, context) async {
      response.setStatusCode(200);
      await response.sendString('ok');
    });
    var server = await fc.serve(port: 0);
    var client = httpClientFactoryMemory.newClient();
    try {
      var text = await httpClientRead(
        client,
        httpMethodGet,
        server.uri!.resolve('handler'),
      );
      expect(text, 'ok');
    } finally {
      client.close();
      await server.close();
    }
  });
}

void main() {
  group('memory', () {
    defineTests(() => AliyunFunctionComputeHttpUniversal(httpServerFactoryMemory));
  });
}
```

### tool/run_test_node.dart

```dart
import 'package:tekartik_build_node/build_node.dart';

Future<void> main() async {
  // Compiles the tests with dart2js and runs them with node (dart_test.yaml
  // must list the node platform).
  await nodeRunTest();
}
```

## Common mistakes

* Naming the Dart function `handler`.
* Calling `serve()` without `port` on the VM (null check error).
* Reading `server.uri` on node without a null check.
* Importing `dart:io` in `bin/main.dart` (breaks the node build).
* Using `aliyunFunctionComputeUniversalMemory` for several tests: export a
  handler on a `newAliyunFunctionComputeUniversalMemory()` per test.
