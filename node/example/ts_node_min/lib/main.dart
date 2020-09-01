import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

Future run({TsClientOptions options}) async {
  options ??= tsClientOptionsFromEnv;
  print('options: $options');
  print('tablestore: $tablestore');
  var client = tablestore.client(options: options);
  print('client: $client');
  var tables = await client.listTableNames();
  print(tables);
}
