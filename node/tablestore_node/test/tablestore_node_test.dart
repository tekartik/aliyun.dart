@TestOn('node')
import 'dart:js_util';

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/import_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_shim.dart';
import 'package:tekartik_aliyun_tablestore_node/src/universal/ts_node_universal.dart';
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
      expect(tsNodeCommon.primaryKeyType.INTEGER,
          tsNodeCommonShim.primaryKeyType.INTEGER);
      expect(tsNodeCommon.primaryKeyType.STRING,
          tsNodeCommonShim.primaryKeyType.STRING);
      expect(tsNodeCommon.primaryKeyType.BINARY,
          tsNodeCommonShim.primaryKeyType.BINARY);
      expect(jsObjectAsMap(tablestoreNode.primaryKeyType),
          {'INTEGER': 1, 'STRING': 2, 'BINARY': 3});
    });
    test('rowExistenceExpectation', () {
      expect(jsObjectAsMap(tablestoreNode.rowExistenceExpectation),
          {'IGNORE': 0, 'EXPECT_EXIST': 1, 'EXPECT_NOT_EXIST': 2});
      expect(tsNodeCommon.rowExistenceExpectation.IGNORE,
          tsNodeCommonShim.rowExistenceExpectation.IGNORE);
      expect(tsNodeCommon.rowExistenceExpectation.EXPECT_EXIST,
          tsNodeCommonShim.rowExistenceExpectation.EXPECT_EXIST);
      expect(tsNodeCommon.rowExistenceExpectation.EXPECT_NOT_EXIST,
          tsNodeCommonShim.rowExistenceExpectation.EXPECT_NOT_EXIST);
    });
    test('ReturnType', () {
      expect(jsObjectAsMap(getProperty(tablestoreJs, 'ReturnType')),
          {'NONE': 0, 'Primarykey': 1, 'AfterModify': 2});
      expect(tsNodeCommon.returnType.NONE, tsNodeCommonShim.returnType.NONE);
      expect(tsNodeCommon.returnType.Primarykey,
          tsNodeCommonShim.returnType.Primarykey);
      expect(tsNodeCommon.returnType.AfterModify,
          tsNodeCommonShim.returnType.AfterModify);
    });
  });
  test('placeholder', () {});
}
