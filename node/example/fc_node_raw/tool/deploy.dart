import 'package:process_run/shell_run.dart';

Future main() async {
  var shell = Shell(workingDirectory: 'deploy');
  await shell.run('fun deploy');
}
