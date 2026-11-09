# tekartik_aliyun_cli

Drive Aliyun's `ossutil64` command line tool (Object Storage Service) from a
Dart VM program or test: find the executable, read its version and build safe
command lines for `package:process_run`. It does not wrap the OSS commands
(for the OSS API in Dart, see `tekartik_aliyun_oss` in the same repo).

## Getting started

Git package, not on pub.dev. Add `process_run` to run the commands:

```yaml
dependencies:
  tekartik_aliyun_cli:
    git:
      url: https://github.com/tekartik/aliyun.dart
      path: io/cli
  process_run: any
```

Install [ossutil](https://help.aliyun.com/document_detail/120075.html) as
`ossutil64` in the `PATH` (or at `/opt/app/ossutil/ossutil64`) and configure
its credentials (`ossutil64 config`), never in a committed file.

```dart
import 'package:process_run/shell_run.dart';
import 'package:tekartik_aliyun_cli/ossutil.dart';

Future<void> main() async {
  // Throws an UnsupportedError when ossutil64 is not found.
  await setupOssutil();
  print(await getOssutilVersion());
  var bucket = 'my-bucket';
  // ossutilShell is escaped, escape your own arguments too.
  var result = await run(
    '$ossutilShell ls ${shellArgument('oss://$bucket/')}',
    verbose: false,
  );
  print(result.outLines.join('\n'));
}
```

Platforms: Dart VM only (Linux, macOS, Windows), not the web nor Flutter
mobile.

## API

| Name | What |
|---|---|
| `setupOssutil()` | finds `ossutil64` (`PATH`, then `/opt/app/ossutil/ossutil64`), once, safe to call concurrently; throws `UnsupportedError` if not found |
| `ossutil` | the path found (`null` before `setupOssutil`), not escaped |
| `ossutilShell` | the same path escaped for a command line |
| `getOssutilVersion()` | the version of `ossutil64 --version`, a `Version` |

## Common pitfalls

* Call `setupOssutil()` before `ossutilShell` or `getOssutilVersion()`: they
  throw otherwise.
* Escape every argument with `shellArgument` (from `process_run`): a bucket,
  a prefix or a local path with a space or a quote breaks the command, or
  runs another one.
* Only `ossutil64` is looked up (ossutil 1.x); the 2.x `ossutil` executable is
  not found.
* In tests, skip when `setupOssutil()` throws (machines without ossutil64).
