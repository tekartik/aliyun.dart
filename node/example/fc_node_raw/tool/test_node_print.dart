import 'package:process_run/shell_run.dart';

Future main() async {
  var shell = Shell();
  await shell.run('pub run test test/print_test.dart -p node');
}
