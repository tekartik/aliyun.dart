# tekartik_aliyun_fc

The runtime independent API of an Aliyun Function Compute HTTP trigger: a
handler gets an `FcHttpRequest`, an `FcHttpResponse` and an `FcHttpContext`.
No runtime here: `tekartik_aliyun_fc_node` runs it on nodejs (Aliyun),
`tekartik_aliyun_fc_http` on a local http server, `tekartik_aliyun_fc_universal`
picks one at compile time.

## Getting started

Git packages, not on pub.dev (a pub workspace, `path` required):

```yaml
dependencies:
  tekartik_aliyun_fc:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/fc
  tekartik_aliyun_fc_universal:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: common/fc_universal
```

```dart
// Re-exports the API (package:tekartik_aliyun_fc/fc.dart, all a handler
// library needs).
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';

Future<void> echoHandler(
  FcHttpRequest request,
  FcHttpResponse response,
  FcHttpContext context,
) async {
  try {
    response.setHeader('content-type', 'text/plain; charset=utf-8');
    await response.sendString('${request.method} ${request.path}');
  } catch (e) {
    response.setStatusCode(500);
    await response.sendString('error');
  }
}

Future<void> main() async {
  aliyunFunctionComputeUniversal.exportHttpHandler(echoHandler);
  // On the Dart VM: http://localhost:4998/handler. No effect on nodejs.
  await aliyunFunctionComputeUniversal.serve(port: 4998);
}
```

## Common pitfalls

* One handler per instance: `exportHttpHandler` can be called only once.
* Always send an answer (`sendString`/`sendBytes`, awaited) and catch your
  errors: the node runtime does not await the handler nor catch its errors
  (the local http runtime answers 500).
* Headers are read-only and looked up case insensitively; there is no
  query map: `Uri.parse(request.url).queryParameters`.
* Aliyun limits a request and an answer to 6 MB of body, 4 KB of headers.

More: the [tekartik-aliyun-fc-handler skill](skills/tekartik-aliyun-fc-handler/SKILL.md).
