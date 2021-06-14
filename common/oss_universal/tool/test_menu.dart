import 'package:dev_test/package.dart';
//import 'package:yyyy_haw_support/gcf_deploy_config.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_aliyun_oss_universal/src/import.dart';
import 'package:tekartik_aliyun_oss_universal/test/environment_client.dart';
import 'package:tekartik_test_menu_io/test_menu_io.dart';

//import '
var shell = Shell();

var env = ShellEnvironment()..aliases['dart_tool'] = 'dart run tool/';

var supportShell = Shell();

var client = ossClientTest;

Future main(List<String> arguments) async {
  mainMenu(arguments, () {
    item('run_ci', () async {
      await packageRunCi('.');
    });
    item('flutter/dart version', () async {
      await shell.run('flutter --version');
      await shell.run('dart --version');
    });

    menu('oss', () {
      item('listBuckets', () async {
        write(jsonPretty((await client!.listBuckets())
            .map((e) => (e as OssBucketMixin).toDebugMap())
            .toList())!);
      });
    });
  });
}
