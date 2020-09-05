/// Support for doing something awesome.
///
/// More dartdocs go here.
library tekartik_aliyun_tablestore_test;

import 'package:tekartik_aliyun_tablestore_test/src/table_test.dart';
import 'package:tekartik_aliyun_tablestore_test/src/row_test.dart';
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

TsClient get tsClientTest => tablestore.client(options: tsClientOptionsFromEnv);

void main() {
  tablestoreTest(tsClientTest);
}

void tablestoreTest(TsClient client) {
  rowTest(client);
  tablesTest(client);
}

// TODO: Export any libraries intended for clients of this package.