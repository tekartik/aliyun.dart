// ignore_for_file: avoid_print

import 'package:tekartik_aliyun_ts_node_min_example/main.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';

Future main(List<String> arguments) async {
  print('env: ${platform.environment}');

  await run();
}
