/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:tekartik_aliyun_tablestore_test/tablestore_test.dart'
    as tablestore_test;
import 'package:tekartik_aliyun_tablestore_universal/environment_client.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';
import 'package:test/test.dart';

TsClient? get tsClientTest =>
    tsClientOptionsFromEnv != null
        ? tablestoreUniversal.client(options: tsClientOptionsFromEnv)
        : null;

void main() {
  tablestoreTest(tsClientTest);
}

void tablestoreTest(TsClient? client) {
  group('universal', () {
    if (client != null) {
      tablestore_test.tablestoreTest(client);
    }
  }, skip: client == null);
}
