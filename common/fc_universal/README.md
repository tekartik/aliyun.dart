# tekartik_aliyun_fc_universal

One Dart entry point for an Aliyun Function Compute HTTP function:
`aliyunFunctionComputeUniversal` is a local `dart:io` http server when run by
the Dart VM (`tekartik_aliyun_fc_http`) and the real Function Compute
function when compiled to JavaScript for the nodejs runtime
(`tekartik_aliyun_fc_node`, it sets `exports.handler`). The same
`bin/main.dart` serves `http://localhost:4998/handler` during development and
becomes `index.js` on Aliyun.

## Getting started

Git packages, not on pub.dev:

```yaml
dependencies:
  tekartik_aliyun_fc_universal:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/fc_universal
dev_dependencies:
  # node build (dart2js), see node/fc_node in this repository
  build_runner: '>=2.15.0'
  build_web_compilers: '>=4.4.19'
```

`bin/main.dart`:

```dart
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';

/// Never name the Dart function `handler`.
Future<void> helloHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  response.setStatusCode(200);
  response.setHeader('content-type', 'text/plain');
  await response.sendString('${request.method} ${request.path}');
}

Future<void> main() async {
  aliyunFunctionComputeUniversal.exportHttpHandler(helloHandler);
  // VM: http://localhost:4998/handler; node: nothing to do, uri is null.
  var server = await aliyunFunctionComputeUniversal.serve(port: 4998);
  print('serving ${server.uri ?? 'on Function Compute'}');
}
```

`dart run bin/main.dart`, then `curl http://localhost:4998/handler/sub`.
The node build and deployment (`build.yaml`, `index.js`, `template.yml`) are
those of [tekartik_aliyun_fc_node](../../node/fc_node/README.md).

In tests, `newAliyunFunctionComputeUniversalMemory()` serves the handler in
memory ([example/main.dart](example/main.dart), `dart run example/main.dart`).

## Platforms

* Dart VM: `aliyunFunctionComputeUniversal` is an http server
  (`serve(port:)`, `port: 0` picks a free port).
* nodejs (dart2js): the Function Compute binding; `serve` does nothing.
* Memory (`aliyunFunctionComputeUniversalMemory`,
  `newAliyunFunctionComputeUniversalMemory()`): every platform.
* Browser: `aliyunFunctionComputeUniversal` throws `UnsupportedError`.

## Common pitfalls

* `serve()` needs `port` on the VM and in memory (null check error without
  it); on node `server.uri` is null.
* One `exportHttpHandler` per instance (name `handler` by default, the first
  path segment: `/handler`, `/handler/sub`; another path gets a 404). Use a
  `newAliyunFunctionComputeUniversalMemory()` per test.
* Never name the Dart handler function `handler`: on node (dart2js) it
  fails at run time (`this.bodyFunction.call$2 is not a function`).
* A handler error is printed and answered 500, on every runtime. Set the
  status and headers before the single `sendString`/`sendBytes`.
* Keep `bin/main.dart` free of `dart:io` and `dart:js`: it must compile for
  both runtimes.

## Testing

```bash
dart test                         # vm
dart run tool/run_test_node.dart  # node (dart2js), needs node on the PATH
```
