import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart';
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:test/test.dart';

void main() {
  group('tablestore', () {
    tablestoreTest(tsClientOptionsFromEnv);
  });
}
