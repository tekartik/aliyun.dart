import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:test/test.dart';

void main() {
  group('tablestore', () {
    test('tablestore', () {
      tablestoreUniversal;
      newTablestoreMemory();
      // ignore: deprecated_member_use_from_same_package
      tablestore;
      // ignore: unnecessary_statements
      getTablestore;
    });
  });
}
