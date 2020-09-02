import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:test/test.dart';

void main() {
  listTablesNamesTest(tsClientOptionsFromEnv);
}

void listTablesNamesTest(TsClientOptions options) {
  test('listTableNames', () async {
    var client = tablestore.client(options: options);
    expect(await client.listTableNames(), const TypeMatcher<List>());
  });
}
