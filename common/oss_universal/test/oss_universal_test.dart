import 'dart:io';

import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';
import 'package:tekartik_aliyun_oss_universal/src/import.dart';
import 'package:tekartik_aliyun_oss_universal/test/environment_client.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:test/test.dart';

var _env = platform.environment;

void main() {
  var bucketName = _env['ossTestBucketName'];
  if (bucketName == null) {
    stderr.writeln('ossTestBucketName not defined as an environment variable');
  }

  // ignore: deprecated_member_use
  debugAliyunOss = true;
  var client = ossClientTest; // ignore: unused_local_variable

  OssBucket _getOrCreatedBucket;
  Future<OssBucket> getOrCreateBucket() async {
    if (_getOrCreatedBucket == null) {
      try {
        _getOrCreatedBucket = await client.getBucket(bucketName);
      } catch (e) {
        if (isLocalTest) {
          return await client.putBucket(bucketName);
        }
        rethrow;
      }
    }
    return _getOrCreatedBucket;
  }

  test('client', () {
    print('client: $client');
    print('options: $ossClientOptionsFromEnv');
  });
  group('oss', () {
    test('createBucket', () async {
      var testBucketName = 'oss_test_bucket';
      var bucket = await client.putBucket(testBucketName);
      expect((await client.listBuckets()).map((e) => e.name),
          contains(bucket.name));
    }, skip: !isLocalTest);
    test('listBuckets', () async {
      var buckets = await client.listBuckets();
      print(buckets);
    });
    test('getBucketInfo', () async {
      var buckets = await client.listBuckets();
      if (buckets?.isNotEmpty ?? false) {
        var firstBucket = buckets.first;
        var bucket = await client.getBucket(firstBucket.name);
        expect(bucket.name, firstBucket.name);
        expect(bucket.location, firstBucket.location);
      }
    });

    group('in bucket', () {
      test('put/get/delete as String', () async {
        var bucket = await getOrCreateBucket();
        var path = 'test/file.txt';
        var content = 'Hello OSS';
        await client.putAsString(bucket.name, path, content);
        expect(await client.getAsString(bucket.name, path), content);
        await client.delete(bucket.name, path);

        await client.delete(bucket.name, path);

        expect(await client.getAsString(bucket.name, path), isNull);
      });
      test('list files', () async {
        var bucket = await getOrCreateBucket();
        var content = 'Hello OSS';
        await client.putAsString(
            bucket.name, 'test/list_files/no/file0.txt', content);
        await client.putAsString(
            bucket.name, 'test/list_files/yes/file1.txt', content);
        await client.putAsString(
            bucket.name, 'test/list_files/yes/sub/file2.txt', content);
        await client.putAsString(bucket.name,
            'test/list_files/yes/other_sub/sub/file3.txt', content);

        var names = <String>[];
        var options =
            OssListFilesOptions(prefix: 'test/list_files/yes/', maxResults: 2);
        var response = await client.list(bucketName, options);
        names.addAll(response.files.map((e) => e.name));
        expect(response.isTruncated, isTrue);
        expect(response.files, hasLength(2));
        while (response.isTruncated) {
          options.marker = response.nextMarker;
          response = await client.list(bucketName, options);
          names.addAll(response.files.map((e) => e.name));
        }
        expect(names, contains('test/list_files/yes/file1.txt'));

        expect(names, contains('test/list_files/yes/sub/file2.txt'));
        expect(names, contains('test/list_files/yes/other_sub/sub/file3.txt'));
        expect(names, isNot(contains('test/list_files/no/file0.txt')));
      });
    }, skip: bucketName == null);
  }, skip: client == null);
}
