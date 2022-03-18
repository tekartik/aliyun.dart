import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:tekartik_aliyun_tablestore_universal_test/tablestore_test.dart';
import 'package:test/test.dart';

void main() {
  group('tablestoreMemory', () {
    tablestoreTest(newTablestoreMemory().client());
  });
}
