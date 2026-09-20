---
name: tekartik-aliyun-cli-ossutil
description: >-
  Use when a Dart command line tool or test on the Dart VM must drive the
  Aliyun ossutil64 OSS command line utility with tekartik_aliyun_cli:
  setupOssutil to locate the executable, the ossutil exe path variable, the
  ossutilShell shell-escaped argument used to build `ossutil64 ls/cp/rm`
  commands with package:process_run (run, Shell), getOssutilVersion returning
  a pub_semver Version, the package:tekartik_aliyun_cli/ossutil.dart import,
  and skipping tests when ossutil64 is not installed.
---

# Driving ossutil64 from Dart (tekartik_aliyun_cli)

`tekartik_aliyun_cli` is a thin Dart VM helper around Aliyun's `ossutil64`
command line utility: it finds the executable, gives you a shell-safe way to
invoke it and reads its version. It does not wrap the OSS commands themselves
- you run them with `package:process_run` (for the Dart OSS API use
`tekartik_aliyun_oss` instead).

## Guidelines

* Dependency (git, not published on pub.dev):
  ```yaml
  dependencies:
    tekartik_aliyun_cli:
      git:
        url: https://github.com/tekartik/aliyun.dart
        path: io/cli
      version: '>=0.1.0'
  ```
  Add `process_run` too, you need it to actually run the commands.
* The single public library is
  `package:tekartik_aliyun_cli/ossutil.dart`, exporting exactly four names:
  `setupOssutil()`, `ossutil`, `ossutilShell` and `getOssutilVersion()`.
  Never import `src/ossutil_impl.dart`.
* `await setupOssutil()` first, always. It is idempotent and lock protected
  (safe to call concurrently): it looks for `ossutil64` in the `PATH`
  (`which`), then falls back to `/opt/app/ossutil/ossutil64`. When nothing is
  found it writes `missing ossutil64 in path` on stderr and throws an
  `UnsupportedError`. Catch that to degrade gracefully or to skip tests.
* `ossutil` is a nullable global `String?` holding the resolved path; it is
  `null` before `setupOssutil()` and must not be interpolated into a command
  line (it is not escaped). Use `ossutilShell` instead: it is the same path
  passed through `shellArgument`, so it survives spaces, and it throws on a
  null `ossutil`.
* Build the command as `'$ossutilShell <args>'` and run it with
  `run(...)` or a `Shell()` from `package:process_run/shell_run.dart`; read
  `outLines` for the parsed output. Keep `verbose: false` when you parse the
  output.
* `getOssutilVersion()` returns a `Version` (`package:pub_semver`, re-exported
  by `package:tekartik_common_utils/version_utils.dart`) by scanning the
  `--version` output for the first `v`-prefixed token; it throws a
  `StateError` when nothing parses. Compare it with `greaterThanOrEqualTo` to
  require a minimum (the package's own test expects `>= 1.6.19`).
* This package is Dart VM / io only (`dart:io`, `which`): do not import it
  from web or node code, and do not use it inside a Function Compute
  function.
* ossutil64 credentials are its own concern: configure them beforehand with
  `ossutil64 config` or with the `-e/-i/-k` flags in the command you build,
  never by committing a config file.
* Testing: always guard on `setupOssutil()` succeeding, with
  `skip: !ossutilSupported` on the group, so that a machine without
  ossutil64 does not fail the suite.

## Examples

### Locate ossutil64 and check its version

```dart
import 'package:tekartik_aliyun_cli/ossutil.dart';
import 'package:tekartik_common_utils/version_utils.dart';

Future<void> main() async {
  try {
    await setupOssutil();
  } on UnsupportedError {
    print('ossutil64 not installed');
    return;
  }
  print('found at $ossutil');
  var version = await getOssutilVersion();
  if (version < Version(1, 6, 19)) {
    print('ossutil64 $version is too old');
  }
}
```

### List and copy objects

```dart
import 'package:process_run/shell_run.dart';
import 'package:tekartik_aliyun_cli/ossutil.dart';

/// Lines of `ossutil64 ls oss://<bucket>/<prefix>`.
Future<List<String>> listObjects(String bucket, String prefix) async {
  await setupOssutil();
  var result = await run(
    '$ossutilShell ls oss://$bucket/$prefix',
    verbose: false,
  );
  return result.outLines.toList();
}

Future<void> uploadDirectory(String localDir, String bucket, String to) async {
  await setupOssutil();
  // ossutilShell is already shell escaped, quote your own arguments.
  await run("$ossutilShell cp -r -f '$localDir' 'oss://$bucket/$to'");
}
```

### A Shell running several ossutil commands

```dart
import 'package:process_run/shell_run.dart';
import 'package:tekartik_aliyun_cli/ossutil.dart';

Future<void> deploy(String bucket, String buildDir) async {
  await setupOssutil();
  var shell = Shell();
  await shell.run('''
$ossutilShell rm -r -f oss://$bucket/web/
$ossutilShell cp -r -f $buildDir oss://$bucket/web/
$ossutilShell ls oss://$bucket/web/
''');
}
```

### Test that skips when ossutil64 is missing

```dart
import 'package:tekartik_aliyun_cli/ossutil.dart';
import 'package:tekartik_common_utils/version_utils.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var ossutilSupported = false;
  try {
    await setupOssutil();
    ossutilSupported = true;
  } catch (_) {}

  group('ossutil', () {
    test('version', () async {
      var version = await getOssutilVersion();
      expect(version, greaterThanOrEqualTo(Version(1, 6, 19)));
    });
  }, skip: !ossutilSupported);
}
```
