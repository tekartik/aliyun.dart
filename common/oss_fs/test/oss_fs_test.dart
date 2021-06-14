import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';
import 'package:test/test.dart';

void main() {
  group('oss_fs', () {
    test('inMemory service', () {
      var service = ossServiceMemory;
      expect(service, isNotNull);
      expect(service, ossServiceMemory);
    });

    test('inMemory blank', () async {
      var service = newOssServiceMemory();
      var client = service.client();
      var bucket = await client.putBucket('test');
      expect(await client.getBucket('test'), isNotNull);
      await client.putAsString(bucket.name, 'test1', 'content1');
      expect(await client.getAsString(bucket.name, 'test1'), 'content1');

      service = newOssServiceMemory();
      client = service.client();
      //expect(await client.getBucket('test'), isNull);
      bucket = await client.putBucket('test');
      expect(await client.getBucket('test'), isNotNull);
      try {
        await client.getAsString(bucket.name, 'test1');
        fail('should fail');
      } on OssException catch (e) {
        expect(e.isNotFound, isTrue);
      }
    });
  });
}
