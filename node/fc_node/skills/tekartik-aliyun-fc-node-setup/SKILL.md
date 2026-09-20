---
name: tekartik-aliyun-fc-node-setup
description: >-
  Use when compiling a Dart entry point to javascript for the Aliyun Function
  Compute nodejs runtime with tekartik_aliyun_fc_node:
  aliyunFunctionComputeNode, AliyunFunctionComputeNode.exportHttpHandler(name:)
  which sets exports.handler, the FcHttpRequest / FcHttpResponse /
  FcHttpContext handler signature, the node interop classes of
  fc_interop.dart (FcHttpRequestNode with queries and getRawBody,
  FcHttpResponseNode with setContentTypeJson, FcHttpContextNode with
  credentials, HttpReqJs, HttpResponseJs, HttpContextJs, Buffer), the
  package:tekartik_aliyun_fc_node/fc_node.dart import, the raw-body node
  module, and the build_runner dart2js build to deploy/index.js with
  template.yml and fun deploy.
---

# Function Compute on nodejs (tekartik_aliyun_fc_node)

`tekartik_aliyun_fc_node` is the nodejs implementation of the
`tekartik_aliyun_fc` API: `aliyunFunctionComputeNode.exportHttpHandler(...)`
sets `exports.handler` on the compiled javascript module, which is exactly
what an Aliyun Function Compute HTTP trigger invokes. The code only runs once
compiled with dart2js and executed by node.

## Guidelines

* Prefer `tekartik_aliyun_fc_universal` for the entry point you actually
  write: it exposes the same API plus a local `dart:io` server, so `dart run
  bin/main.dart` works during development. Depend on
  `tekartik_aliyun_fc_node` directly only when the code is node-only.
* Dependency (git, not published on pub.dev), plus the node tool chain of the
  [node app setup](https://github.com/tekartik/app_node_utils.dart/tree/master/app_build):
  ```yaml
  dependencies:
    tekartik_aliyun_fc_node:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: node/fc_node
      version: '>=0.2.2'
  dev_dependencies:
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.4.19'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
  ```
* Two public libraries:
  * `package:tekartik_aliyun_fc_node/fc_node.dart` exports the single name
    `aliyunFunctionComputeNode`. It does **not** re-export the
    `tekartik_aliyun_fc` API, so also import
    `package:tekartik_aliyun_fc/fc_api.dart` for `FcHttpRequest`,
    `FcHttpResponse`, `FcHttpContext`, `FcHttpHandler` and
    `AliyunFunctionCompute`.
  * `package:tekartik_aliyun_fc_node/fc_interop.dart` holds the node
    specific classes: `FcHttpRequestNode`, `FcHttpResponseNode`,
    `FcHttpContextNode` and the raw js interop types `HttpReqJs`,
    `HttpResponseJs`, `HttpContextJs`, `Buffer`. You need it only to reach
    the node-only extras.
* `aliyunFunctionComputeNode.exportHttpHandler(handler, {name = 'handler'})`
  can be called **once**: it sets `exports.<name>` through `node_interop`.
  `name` must match the `Handler: index.<name>` of the Function Compute
  template. Never call your own Dart function `handler`.
* The handler is
  `(FcHttpRequest request, FcHttpResponse response, FcHttpContext context)`.
  Read `request.method`, `request.path`, `request.url`, `request.headers`
  (always lower-cased keys) and `await request.getBodyString()` /
  `await request.getBodyBytes()`. Body reading goes through the `raw-body`
  node module (`require('raw-body')`), provided by the Function Compute
  nodejs runtime; add it to `package.json` if you run the compiled js
  elsewhere. The body is cached, so calling it twice is fine, but do not mix
  the string and the bytes flavours on the same request.
* Respond exactly once: `response.setStatusCode(code)` and
  `response.setHeader(key, value)` **before** the single
  `await response.sendString(text)` or `await response.sendBytes(bytes)`
  (bytes go out through a node `Buffer`). Nothing else terminates the
  invocation, so wrap your logic in a try/catch and always send something.
* Node-only extras, behind an `is` check on the abstract type:
  `FcHttpRequestNode.queries` (the parsed query string as a
  `Map<String, dynamic>?`) and `getRawBody()`,
  `FcHttpResponseNode.setContentTypeJson()`, and
  `FcHttpContextNode.credentials` (the STS credentials the function runs
  with). The base `FcHttpContext` has no member at all.
* This package cannot run on the Dart VM (`dart:js`, `node_interop`): declare
  `platforms: [ vm, node ]` in `dart_test.yaml` but keep the node-only code
  out of vm tests, and build with `build_web_compilers` in `dart2js` mode.
* Build and deploy: `dart run build_runner build --output=build/ -- -p node`,
  copy `build/bin/main.dart.js` to `deploy/index.js`, then `fun deploy` from
  `deploy/` with a `template.yml` declaring
  `Handler: index.handler`, `Runtime: nodejs12` and an `httpTrigger` event.

## Examples

### bin/main.dart, the exported function

```dart
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_aliyun_fc_node/fc_node.dart';

void main() {
  // Sets exports.handler on the compiled index.js.
  aliyunFunctionComputeNode.exportHttpHandler((
    FcHttpRequest request,
    FcHttpResponse response,
    FcHttpContext context,
  ) async {
    try {
      var body = await request.getBodyString();
      response.setStatusCode(200);
      response.setHeader('content-type', 'application/json');
      await response.sendString(
        '{"method": "${request.method}", "path": "${request.path}", '
        '"length": ${body.length}}',
      );
    } catch (e) {
      response.setStatusCode(500);
      await response.sendString('error: $e');
    }
  });
}
```

### Routing on the path, binary answer

```dart
import 'dart:typed_data';

import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_aliyun_fc_node/fc_node.dart';

void main() {
  aliyunFunctionComputeNode.exportHttpHandler(myHandler, name: 'api');
}

Future<void> myHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  // headers keys are lower cased by the implementation.
  var token = request.headers['authorization'];
  if (token == null) {
    response.setStatusCode(401);
    await response.sendString('missing authorization');
    return;
  }
  switch (request.path.split('/').last) {
    case 'echo':
      var bytes = await request.getBodyBytes();
      response.setStatusCode(200);
      response.setHeader('content-type', 'application/octet-stream');
      await response.sendBytes(bytes);
    case 'ping':
      response.setStatusCode(200);
      await response.sendBytes(Uint8List.fromList('pong'.codeUnits));
    default:
      response.setStatusCode(404);
      await response.sendString('not found');
  }
}
```

### Node-only extras: queries, credentials, json content type

```dart
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_aliyun_fc_node/fc_interop.dart';
import 'package:tekartik_aliyun_fc_node/fc_node.dart';

void main() {
  aliyunFunctionComputeNode.exportHttpHandler((
    FcHttpRequest request,
    FcHttpResponse response,
    FcHttpContext context,
  ) async {
    Map<String, dynamic>? queries;
    if (request is FcHttpRequestNode) {
      // Parsed query string, node implementation only.
      queries = request.queries;
    }
    if (context is FcHttpContextNode) {
      // STS credentials of the running function.
      print('credentials: ${context.credentials?.keys}');
    }
    response.setStatusCode(200);
    if (response is FcHttpResponseNode) {
      response.setContentTypeJson();
    }
    await response.sendString('{"id": "${queries?['id']}"}');
  });
}
```

### build.yaml and the node build

```yaml
targets:
  $default:
    sources:
      - "$package$"
      - "lib/**"
      - "bin/**"
      - "test/**"
    builders:
      build_web_compilers|entrypoint:
        generate_for:
          - bin/**
        options:
          compiler: dart2js
```

```bash
# compile bin/main.dart to javascript
dart run build_runner build --output=build/ -- -p node
# index.js is what template.yml points at (Handler: index.handler)
cp build/bin/main.dart.js deploy/index.js
cd deploy && fun deploy
```

### tool/run_test_node.dart

```dart
import 'package:tekartik_build_node/build_node.dart';

Future<void> main() async {
  // dart2js compile of the tests, then run them with node.
  await nodePackageRunTest('.');
}
```
