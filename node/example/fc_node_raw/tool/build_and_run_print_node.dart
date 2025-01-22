import 'package:path/path.dart';
import 'package:tekartik_app_node_build/app_build.dart';

Future main() async {
  var builder = NodeAppBuilder(
      options: NodeAppOptions(srcFile: join('bin', 'print.dart')));
  await builder.buildAndRun();
}
