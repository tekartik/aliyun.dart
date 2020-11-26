import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';
import 'package:test/test.dart';

void main() {
  group('oss_fs', () {
    test('inMemory', () {
      var service = ossServiceFsMemory;
      expect(service, isNotNull);
      expect(service, ossServiceFsMemory);
    });
  });
}
