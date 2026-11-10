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
  module, handler errors answered 500, and the dart2js build to
  deploy/index.js (afcNodeBuild) with template.yml and fun deploy.
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
  (always lower-cased keys) and `await request.getBodyString()` (UTF-8) /
  `await request.getBodyBytes()`. Body reading goes through the `raw-body`
  node module (`require('raw-body')`), provided by the Function Compute
  nodejs runtime; add it to `package.json` if you run the compiled js
  elsewhere, version 2.x or 3.x (4.x exports an object, not a function, and
  every body read fails). The body bytes are read once: the string and the
  bytes flavours can both be called, in any order.
* Respond exactly once: `response.setStatusCode(code)` and
  `response.setHeader(key, value)` **before** the single
  `await response.sendString(text)` or `await response.sendBytes(bytes)`
  (bytes go out through a node `Buffer`). The handler is awaited: an error
  (thrown or a failed future) is printed and answered with a 500 `error`
  (as `tekartik_aliyun_fc_http` does). A handler that returns without
  sending anything leaves the client waiting until the function timeout.
* Node-only extras, behind an `is` check on the abstract type:
  `FcHttpRequestNode.queries` (the parsed query string as a
  `Map<String, dynamic>?`) and `getRawBody()`,
  `FcHttpResponseNode.setContentTypeJson()`, and
  `FcHttpContextNode.credentials` (the STS credentials the function runs
  with: access key id, secret and security token). The base `FcHttpContext`
  has no member at all. Never print the context: its `toString()` holds the
  credentials in clear.
* This package cannot run on the Dart VM (`dart:js`, `node_interop`): declare
  `platforms: [ vm, node ]` in `dart_test.yaml` but keep the node-only code
  out of vm tests, and build with `build_web_compilers` in `dart2js` mode.
* Build and deploy: `afcNodeBuild()` from
  `package:tekartik_app_node_build/afc_build.dart` (dev dependency
  `tekartik_app_node_build`, `https://github.com/tekartik/app_node_utils.dart`,
  `app_build`) compiles `bin/main.dart` with build_runner in dart2js mode,
  adds the node preamble and copies `build/bin/main.dart.js` to
  `deploy/index.js`; then `fun deploy` from `deploy/` (or `afcNodeDeploy()`)
  with a `template.yml` declaring `Handler: index.handler`, a nodejs
  `Runtime` and an `httpTrigger` event.

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
    // An exception here is answered with a 500 by the runtime wrapper.
    var body = await request.getBodyString();
    response.setStatusCode(200);
    response.setHeader('content-type', 'application/json');
    await response.sendString(
      '{"method": "${request.method}", "path": "${request.path}", '
      '"length": ${body.length}}',
    );
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

```dart
// tool/build_and_deploy.dart
import 'package:tekartik_app_node_build/afc_build.dart';

Future<void> main() async {
  // bin/main.dart -> deploy/index.js (Handler: index.handler)
  await afcNodeBuild();
  // fun deploy in deploy/
  var result = await afcNodeDeploy();
  print('url: ${result.url}');
}
```

### tool/run_test_node.dart

```dart
import 'package:tekartik_build_node/build_node.dart';

Future<void> main() async {
  // dart2js compile of the tests, then run them with node.
  await nodePackageRunTest('.');
}
```
