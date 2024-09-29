/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_test/src/row_test.dart';
import 'package:tekartik_aliyun_tablestore_test/src/table_test.dart';
import 'package:test/test.dart';

void tablestoreTest(TsClient client) {
  group('tablestore', () {
    rowTest(client);
    tablesTest(client);
  });
}
