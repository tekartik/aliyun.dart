import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:test/test.dart';
import 'package:tekartik_common_utils/env_utils.dart';

void main() {
  tablesTest(tsClientOptionsFromEnv);
}

void tablesTest(TsClientOptions options) {
  TsClient client;
  setUpAll(() {
    client = tablestore.client(options: options);
  });
  test('deleteTable', () async {
    var tableName = 'test_dummy_to_delete';
    try {
      await client.deleteTable(tableName);
    } catch (_) {}
    var names = await client.listTableNames();
    expect(names, isNot(contains(tableName)));
  });
  test('listTableNames', () async {
    expect(await client.listTableNames(), const TypeMatcher<List>());
  });
  test('createTable', () async {
    // We are limited in the number of create, test it well and sometimes delete!
    var tableName = 'test_create1';
    var names = await client.listTableNames();
    if (!names.contains(tableName)) {
      await client.createTable(tableName);
    }
    names = await client.listTableNames();
    expect(names, contains(tableName));
  });
  test('describeTable', () async {
    // We are limited in the number of create, test it well and sometimes delete!
    var tableName = 'test_create1';
    var names = await client.listTableNames();
    if (!names.contains(tableName)) {
      await client.createTable(tableName);
    }
    names = await client.listTableNames();
    expect(names, contains(tableName));

    var tableDescription = await client.describeTable(tableName);
    var tableMeta = tableDescription.tableMeta;
    expect(tableMeta.tableName, tableName);

    if (isRunningAsJavascript) {
      // TODO only for node, to check soon!
      expect(tableMeta.primaryKeys.length, 2);
      expect(tableMeta.primaryKeys[0].name, 'gid');
      expect(tableMeta.primaryKeys[0].type, TsColumnType.integer);
    }
  });
}
