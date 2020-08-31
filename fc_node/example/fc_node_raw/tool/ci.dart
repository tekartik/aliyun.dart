import 'package:process_run/shell_run.dart';

Future main() async {
  var shell = Shell();
  await shell.run('pub run test -p vm,node');
  await shell.run('pub run build_runner build --output=build/  -- -p node');
}
