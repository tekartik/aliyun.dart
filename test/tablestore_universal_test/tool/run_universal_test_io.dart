import 'package:process_run/shell_run.dart';

Future main() async {
  await run('dart test -p vm');
}
