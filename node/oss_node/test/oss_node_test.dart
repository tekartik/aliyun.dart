import 'package:tekartik_aliyun_oss_node/environment_client.dart';

import 'package:tekartik_aliyun_oss_node/oss_service.dart';
import 'package:tekartik_aliyun_oss_node/src/oss_service_node.dart';
import 'package:test/test.dart';

OssClient get tsClientTest => ossClientOptionsFromEnv != null
    ? ossServiceNode.client(options: ossClientOptionsFromEnv)
    : null;

void main() {
  var client = tsClientTest; // ignore: unused_local_variable
  test('client', () {
    print('client: $client');
    print('options: $ossClientOptionsFromEnv');
  });
  group('tablestore_node', () {
    test('listBuckets', () async {
      var buckets = await client.listBuckets();
      print(buckets);
    });
  }, skip: client == null);
}
