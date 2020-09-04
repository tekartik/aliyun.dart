@TestOn('node')
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/tablestore_node.dart';
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:test/test.dart';

void main() {
  group('tablestore_node', () {
    TsClient client; // ignore: unused_local_variable
    setUpAll(() {
      client = tablestoreNode.client(options: tsClientOptionsFromEnv);
    });
    test('keyType', () {
      expect(tablestoreNode.primaryKeyType.INTEGER, 1);
      expect(tablestoreNode.primaryKeyType.STRING, 2);
      expect(tablestoreNode.primaryKeyType.BINARY, 3);
    });
  });
  test('placeholder', () {});
}
