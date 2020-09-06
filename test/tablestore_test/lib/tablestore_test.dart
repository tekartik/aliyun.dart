/// Support for doing something awesome.
///
/// More dartdocs go here.
library tekartik_aliyun_tablestore_test;

import 'package:tekartik_aliyun_tablestore_test/src/table_test.dart';
import 'package:tekartik_aliyun_tablestore_test/src/row_test.dart';
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:test/test.dart';

TsClient get tsClientTest => tsClientOptionsFromEnv != null
    ? tablestore.client(options: tsClientOptionsFromEnv)
    : null;

void main() {
  tablestoreTest(tsClientTest);
}

void tablestoreTest(TsClient client) {
  group('tablestore', () {
    rowTest(client);
    tablesTest(client);
  }, skip: client == null);
}
