import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:test/test.dart';

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
    tablestoreTest(tsClientTest);
  });
  test('placeholder', () {});
}
