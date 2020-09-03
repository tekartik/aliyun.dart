/// Support for doing something awesome.
///
/// More dartdocs go here.
library tekartik_aliyun_tablestore_test;

import 'package:tekartik_aliyun_tablestore_test/src/table_test.dart';
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

void main() {
  tablestoreTest(tsClientOptionsFromEnv);
}

void tablestoreTest(TsClientOptions options) {
  tablesTest(options);
}

// TODO: Export any libraries intended for clients of this package.
