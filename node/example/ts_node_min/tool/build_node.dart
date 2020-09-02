import 'package:process_run/shell_run.dart';
import 'copy_to_deploy.dart' as copy_to_deploy;

Future main() async {
  var shell = Shell();
  await shell.run('pub run build_runner build --output=build/  -- -p node');
  await copy_to_deploy.main();
}
