import 'package:tekartik_aliyun_oss_fs/oss_fs_io.dart';
import 'package:test/test.dart';

void main() {
  group('oss_fs', () {
    test('inMemory', () {
      var service = ossServiceFsIo;
      expect(service, isNotNull);
      expect(service, ossServiceFsIo);
    });
  });
}
