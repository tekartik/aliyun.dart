import 'package:process_run/shell_run.dart';

Future main() async {
  var shell = Shell();
  await shell.run('dart test test/print_test.dart -p node');
}
