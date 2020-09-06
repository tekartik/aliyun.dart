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

TsClient get tsClientTest => tsClientOptionsFromEnv != null
    ? tablestoreNode.client(options: tsClientOptionsFromEnv)
    : null;
void main() {
  var client = tsClientTest; // ignore: unused_local_variable
  group('tablestore_node', () {
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
    test('ComparatorType', () {
      expect(jsObjectAsMap(getProperty(tablestoreJs, 'ComparatorType')), {
        'EQUAL': 1,
        'NOT_EQUAL': 2,
        'GREATER_THAN': 3,
        'GREATER_EQUAL': 4,
        'LESS_THAN': 5,
        'LESS_EQUAL': 6
      });
      expect(tsNodeCommon.comparatorType.EQUAL,
          tsNodeCommonShim.comparatorType.EQUAL);
      expect(tsNodeCommon.comparatorType.NOT_EQUAL,
          tsNodeCommonShim.comparatorType.NOT_EQUAL);
      expect(tsNodeCommon.comparatorType.GREATER_THAN,
          tsNodeCommonShim.comparatorType.GREATER_THAN);
      expect(tsNodeCommon.comparatorType.GREATER_EQUAL,
          tsNodeCommonShim.comparatorType.GREATER_EQUAL);
      expect(tsNodeCommon.comparatorType.LESS_THAN,
          tsNodeCommonShim.comparatorType.LESS_THAN);
      expect(tsNodeCommon.comparatorType.LESS_EQUAL,
          tsNodeCommonShim.comparatorType.LESS_EQUAL);
    });

    test('LogicalOperator', () {
      expect(jsObjectAsMap(getProperty(tablestoreJs, 'LogicalOperator')),
          {'NOT': 1, 'AND': 2, 'OR': 3});
      expect(tsNodeCommon.logicalOperator.NOT,
          tsNodeCommonShim.logicalOperator.NOT);
      expect(tsNodeCommon.logicalOperator.AND,
          tsNodeCommonShim.logicalOperator.AND);
      expect(
          tsNodeCommon.logicalOperator.OR, tsNodeCommonShim.logicalOperator.OR);
    });
  }, skip: client == null);
}
