import 'package:tekartik_app_node_build/afc_build.dart';

import 'deploy.dart';

Future main() async {
  await afcNodeBuild();
  await deploy();
}
