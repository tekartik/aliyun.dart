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

    test('list pages with marker', () async {
      var client = newOssServiceMemory().client();
      var bucket = await client.putBucket('test');
      for (var i = 1; i <= 5; i++) {
        await client.putAsString(bucket.name, 'dir/f$i.txt', 'c$i');
      }
      var options = OssListFilesOptions(prefix: 'dir/', maxResults: 2);
      var pages = <List<String>>[];
      while (true) {
        var response = await client.list(bucket.name, options);
        pages.add(response.files.map((file) => file.name).toList());
        if (!response.isTruncated) {
          break;
        }
        options.marker = response.nextMarker;
      }
      expect(pages, [
        ['dir/f1.txt', 'dir/f2.txt'],
        ['dir/f3.txt', 'dir/f4.txt'],
        ['dir/f5.txt'],
      ]);

      // A marker after every file returns nothing
      var response = await client.list(
        bucket.name,
        OssListFilesOptions(prefix: 'dir/', marker: 'zzz'),
      );
      expect(response.files, isEmpty);
    });

    test('list prefix is a string prefix', () async {
      var client = newOssServiceMemory().client();
      var bucket = await client.putBucket('test');
      for (var name in [
        'dir/f1.txt',
        'dir/f2.txt',
        'dir/sub/f3.txt',
        'dir.txt',
        'dir2/x.txt',
        'other.txt',
      ]) {
        await client.putAsString(bucket.name, name, 'content');
      }
      Future<List<String>> names(String? prefix) async => (await client.list(
        bucket.name,
        OssListFilesOptions(prefix: prefix),
      )).files.map((file) => file.name).toList();
      // Like OSS, not a directory: 'dir/f' and 'dir' match keys starting so.
      expect(await names('dir/f'), ['dir/f1.txt', 'dir/f2.txt']);
      expect(await names('dir'), [
        'dir.txt',
        'dir/f1.txt',
        'dir/f2.txt',
        'dir/sub/f3.txt',
        'dir2/x.txt',
      ]);
      expect(await names('dir/'), [
        'dir/f1.txt',
        'dir/f2.txt',
        'dir/sub/f3.txt',
      ]);
      expect(await names('dir/sub/'), ['dir/sub/f3.txt']);
      expect(await names('none'), isEmpty);
      expect(await names('none/'), isEmpty);
      expect(await names(''), hasLength(6));
      expect(await names(null), hasLength(6));
    });
  });
}
