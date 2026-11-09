// ignore_for_file: avoid_print

/// Prints the ossutil64 version and lists a bucket.
///
/// `dart run example/main.dart <bucket>`, with ossutil64 installed and
/// configured (`ossutil64 config`).
library;

import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:tekartik_aliyun_cli/ossutil.dart';

Future<void> main(List<String> arguments) async {
  try {
    await setupOssutil();
  } on UnsupportedError {
    print('ossutil64 not installed');
    return;
  }
  print('ossutil64 $ossutil version ${await getOssutilVersion()}');
  if (arguments.isEmpty) {
    stderr.writeln('usage: main.dart <bucket>');
    return;
  }
  var bucket = arguments.first;
  // Every argument escaped, ossutilShell already is.
  var result = await run(
    '$ossutilShell ls ${shellArgument('oss://$bucket/')}',
    verbose: false,
  );
  print(result.outLines.join('\n'));
}
