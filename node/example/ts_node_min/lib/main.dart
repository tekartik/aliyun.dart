import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

Future run({TsClientOptions? options}) async {
  var tablestore = tablestoreUniversal;
  options ??= tsClientOptionsFromEnv;
  print('options: $options');
  print('tablestore: $tablestore');
  var client = tablestore.client(options: options);
  print('client: $client');
  var tableNames = await client.listTableNames();
  print(tableNames);
  for (var tableName in tableNames) {
    var desc = await client.describeTable(tableName);
    print(desc);
  }
}
