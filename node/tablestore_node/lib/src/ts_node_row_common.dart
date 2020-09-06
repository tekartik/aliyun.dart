import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/import.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_tablestore_common.dart';
import 'package:tekartik_common_utils/model/model.dart';

Map<String, dynamic> toPrimaryKeyValueParam(TsKeyValue keyValue) =>
    <String, dynamic>{keyValue.name: keyValue.value};

Map<String, dynamic> toGetRowParams(TsGetRowRequest request) {
  var map = Model({
    if (request.tableName != null) 'tableName': request.tableName,
    if (request.primaryKey != null)
      // !singular
      'primaryKey': request.primaryKey.list
          .map(toPrimaryKeyValueParam)
          .toList(growable: false),
    if (request.columns != null) 'columnsToGet': request.columns,
  });
  return map;
}

Map<String, dynamic> toPutRowParams(TsPutRowRequest request) {
  var map = Model({
    if (request.tableName != null) 'tableName': request.tableName,
    // Needed
    'condition': request.condition ?? TsCondition.ignore,
    if (request.primaryKey != null)
      // !singular
      'primaryKey': request.primaryKey.list
          .map(toPrimaryKeyValueParam)
          .toList(growable: false),
    if (request.data != null)
      'attributeColumns':
          request.data.map((e) => {e.name: e.value}).toList(growable: false),
    'returnContent': {'returnType': tsNodeCommon.returnType.Primarykey}
  });
  return map;
}

Map<String, dynamic> toDeleteRowParams(TsDeleteRowRequest request) {
  var map = Model({
    if (request.tableName != null) 'tableName': request.tableName,
    // Needed
    'condition': request.condition ?? TsCondition.ignore,
    if (request.primaryKey != null)
      // !singular
      'primaryKey': request.primaryKey.list
          .map(toPrimaryKeyValueParam)
          .toList(growable: false),
  });
  return map;
}

int tsConditionRowExistenceExpectationToNative(
    TsConditionRowExistenceExpectation rowExistenceExpecation) {
  switch (rowExistenceExpecation) {
    case TsConditionRowExistenceExpectation.ignore:
      return tsNodeCommon.rowExistenceExpectation.IGNORE;
    case TsConditionRowExistenceExpectation.expectExist:
      return tsNodeCommon.rowExistenceExpectation.EXPECT_EXIST;
    case TsConditionRowExistenceExpectation.expectNotExist:
      return tsNodeCommon.rowExistenceExpectation.EXPECT_NOT_EXIST;
  }
  throw 'condition $rowExistenceExpecation not supported';
}

int tsComparatorTypeToNative(TsComparatorType operatorType) {
  switch (operatorType) {
    case TsComparatorType.equals:
      return tsNodeCommon.comparatorType.EQUAL;
    case TsComparatorType.notEquals:
      return tsNodeCommon.comparatorType.NOT_EQUAL;
    case TsComparatorType.greaterThan:
      return tsNodeCommon.comparatorType.GREATER_THAN;
    case TsComparatorType.greatorThanOrEquals:
      return tsNodeCommon.comparatorType.GREATER_EQUAL;
    case TsComparatorType.lessThan:
      return tsNodeCommon.comparatorType.LESS_THAN;
    case TsComparatorType.lessThanOrEquals:
      return tsNodeCommon.comparatorType.LESS_EQUAL;
  }
  throw 'condition $operatorType not supported';
}
