import 'package:process_run/shell_run.dart';

Future main() async {
  await run('pub run test -p vm');
}
