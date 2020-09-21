import 'package:tekartik_aliyun_tablestore_universal_test/tablestore_test.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:test/test.dart';
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';

void main() {
  group('tablestore', () {
    var env = platform.environment;
    if (env['TRAVIS'] != null) {
      // skip
      return;
    }
    // skip on vm for now too
    if (platformContext.io != null) {
      // skip
      // return;
    }
    test('options', () {
      print('options: $tsClientOptionsFromEnv');
    });
    tablestoreTest(tsClientTest);
  });
  test('placeholder', () {});
}
