@TestOn('node')
import 'package:tekartik_aliyun_oss_node/environment_client.dart';
import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:test/test.dart';

OssClient? get tsClientTest => ossNodeClientOptionsFromEnv != null
    ? ossServiceNode.client(options: ossNodeClientOptionsFromEnv)
    : null;

void main() {
  var client = tsClientTest; // ignore: unused_local_variable
  test('client', () {
    print('client: $client');
    print('options: $ossNodeClientOptionsFromEnv');
  });
  group('oss_node', () {
    test('listBuckets', () async {
      var buckets = await client!.listBuckets();
      print(buckets);
    });
  }, skip: client == null);
}
