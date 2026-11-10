# tekartik_aliyun_fc_node

Aliyun Function Compute (FC) HTTP functions written in Dart for the FC
nodejs runtime. The Dart entry point is compiled to JavaScript (dart2js) and
`aliyunFunctionComputeNode.exportHttpHandler` sets `exports.handler`, the
function an FC HTTP trigger calls. Handlers use the runtime independent
`tekartik_aliyun_fc` API (`FcHttpRequest`, `FcHttpResponse`,
`FcHttpContext`), so the same handler also runs in memory or on `dart:io`
with `tekartik_aliyun_fc_http` (`tekartik_aliyun_fc_universal` picks one).

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_aliyun_fc:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/fc
  tekartik_aliyun_fc_node:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: node/fc_node
dev_dependencies:
  build_runner: '>=2.15.0'
  build_web_compilers: '>=4.4.19'
  tekartik_app_node_build:
    git:
      url: https://github.com/tekartik/app_node_utils.dart
      path: app_build
```

`bin/main.dart`, the function:

```dart
import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_node/fc_node.dart';

Future<void> helloHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  var body = await request.getBodyString();
  response.setStatusCode(200);
  response.setHeader('content-type', 'text/plain');
  await response.sendString('${request.method} ${request.path} $body');
}

void main() {
  // Sets exports.handler: `Handler: index.handler` in template.yml.
  aliyunFunctionComputeNode.exportHttpHandler(helloHandler);
}
```

`build.yaml` (dart2js for `bin/`) and `tool/build.dart`:

```yaml
targets:
  $default:
    sources:
      - "$package$"
      - "lib/**"
      - "bin/**"
    builders:
      build_web_compilers|entrypoint:
        generate_for:
          - bin/**
        options:
          compiler: dart2js
```

```dart
import 'package:tekartik_app_node_build/afc_build.dart';

Future<void> main() async {
  // bin/main.dart -> build/bin/main.dart.js (node preamble added)
  // -> deploy/index.js
  await afcNodeBuild();
}
```

Then deploy `deploy/` (with a `template.yml` declaring a nodejs function,
`Handler: index.handler` and an `HTTP` event) with `fun deploy`, or
`afcNodeDeploy()` from the same library.

## Platforms

Node.js only: the library uses `dart:js` and `node_interop` (dart2js). For
the Dart VM (tests, a local server) use `tekartik_aliyun_fc_http`, or write
the entry point with `tekartik_aliyun_fc_universal`.

## The handler

* `request.method`, `request.path`, `request.url`, `request.headers` (lower
  case keys, case insensitive lookup), `await request.getBodyString()`
  (UTF-8) and `await request.getBodyBytes()`: the body is read once and
  both can be called.
* `response.setStatusCode(code)` and `response.setHeader(name, value)`,
  then once `await response.sendString(text)` or
  `await response.sendBytes(bytes)`.
* Node only extras (`package:tekartik_aliyun_fc_node/fc_interop.dart`):
  `FcHttpRequestNode.queries` (the parsed query), `FcHttpResponseNode`
  `setContentTypeJson()`, `FcHttpContextNode.credentials` (the temporary
  credentials of the function).

## Common pitfalls

* Answer once, status and headers first. A handler that returns without
  sending leaves the client waiting until the function timeout.
* A handler error (thrown or a failed future) is printed and answered with a
  500 `error`.
* The body is read with the `raw-body` node module, shipped by the FC nodejs
  runtime. When you deploy your own `node_modules`, use `raw-body` 2.x or
  3.x: 4.x exports an object, not a function, and reading a body fails.
* `FcHttpContextNode.credentials` holds the access key secret and the
  security token of the function: never print the context.
* `exportHttpHandler` sets `exports.<name>` (`handler` by default): `name`
  must match `Handler: index.<name>`. Call it once.
* Tests of this package run on node with the `raw-body` module of
  `package.json` (`npm install`, `dart test -p node`).
