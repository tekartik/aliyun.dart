import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_common_utils/version_utils.dart';

/// Exe path
String? ossutil;

String get ossutilShell => shellArgument(ossutil!);
var _lock = Lock();

Future setupOssutil() async {
  if (ossutil == null) {
    await _lock.synchronized(() async {
      ossutil ??= await which('ossutil64');
      if (ossutil == null) {
        Future tryPath(String path) async {
          var file = File(path);
          var stat = file.statSync();
          if (stat.type != FileSystemEntityType.notFound) {
            // await makeExecutableIfNeeded(file);
            ossutil = path;
          }
        }

        await tryPath('/opt/app/ossutil/ossutil64');
      }
    });
  }
  if (ossutil == null) {
    stderr.writeln('missing ossutil64 in path');
    throw UnsupportedError('ossutil');
  }
}

Future<Version> getOssutilVersion() async {
  var lines = (await run('$ossutilShell --version', verbose: false)).outLines;
  for (var line in lines) {
    for (var word in line.split(' ')) {
      var versionText = word.trim();
      if (versionText.startsWith('v')) {
        versionText = versionText.substring(1);
      }
      try {
        var version = parseVersion(versionText);
        return version;
      } catch (_) {}
    }
  }
  throw StateError('$ossutil not found');
}
