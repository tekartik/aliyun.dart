@TestOn('vm')
library;

import 'package:process_run/shell.dart';
import 'package:tekartik_aliyun_tablestore_node/environment_client.dart';
import 'package:test/test.dart';

void main() {
  var options = getTsClientOptionsFromEnv(userEnvironment);
  group('tablestore_universal', () {
    test('options', () {
      print('options: $options');
      print('accessKeyId: ${options?.accessKeyId}');
    });
  });
}
