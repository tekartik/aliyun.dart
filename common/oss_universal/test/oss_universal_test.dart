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

  var _getOrCreatedDone = false;
  Future<OssBucket> getOrCreateBucket() async {
    if (!_getOrCreatedDone) {
      try {
        var bucket = await client.getBucket(bucketName);
        _getOrCreatedDone = true;
        return bucket;
      } catch (e) {
        if (isLocalTest) {
          return await client.putBucket(bucketName);
        }
        rethrow;
      }
    }
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
    }, skip: bucketName == null);
  }, skip: client == null);
}
