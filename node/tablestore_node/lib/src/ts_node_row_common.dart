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
      'primaryKey': tsPrimaryKeyParams(request.primaryKey),
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
      'primaryKey': tsPrimaryKeyParams(request.primaryKey),
    if (request.data != null)
      'attributeColumns': tsAttributeColumnsParams(request.data),
    'returnContent': {'returnType': tsNodeCommon.returnType.Primarykey}
  });
  return map;
}

Map<String, dynamic> toUpdateRowParams(TsUpdateRowRequest request) {
  var map = Model({
    if (request.tableName != null) 'tableName': request.tableName,
    // Needed
    'condition': request.condition ?? TsCondition.expectExist,
    if (request.primaryKey != null)
      // !singular
      'primaryKey': tsPrimaryKeyParams(request.primaryKey),
    if (request.data != null)
      'updateOfAttributeColumns': tsUpdateAttributesParams(request.data),
    'returnContent': {'returnType': tsNodeCommon.returnType.Primarykey}
  });
  return map;
}

List<dynamic> tsAttributeColumnsParams(List<TsAttribute> attributes) =>
    attributes.map((e) => toPrimaryKeyValueParam(e)).toList();

Map<String, dynamic> tsUpdateAttributeParams(
    TsUpdateAttribute updateAttribute) {
  if (updateAttribute is TsUpdateAttributePut) {
    return <String, dynamic>{
      'PUT': tsAttributeColumnsParams(updateAttribute.attributes)
    };
  } else if (updateAttribute is TsUpdateAttributeDelete) {
    return <String, dynamic>{'DELETE_ALL': TsArrayHack(updateAttribute.fields)};
  } else {
    throw UnsupportedError('Unsupported update attribute $updateAttribute');
  }
}

List<Map<String, dynamic>> tsUpdateAttributesParams(
        List<TsUpdateAttribute> attributes) =>
    attributes.map((e) => tsUpdateAttributeParams(e)).toList();
List<dynamic> tsPrimaryKeyParams(TsPrimaryKey primaryKey) =>
    primaryKey.list.map(toPrimaryKeyValueParam).toList();

List<Map<String, dynamic>> primaryKeyAsList(TsPrimaryKey primaryKey) =>
    primaryKey.list.map(toPrimaryKeyValueParam).toList(growable: false);

Map<String, dynamic> toDeleteRowParams(TsDeleteRowRequest request) {
  var map = Model({
    if (request.tableName != null) 'tableName': request.tableName,
    // Needed
    'condition': request.condition ?? TsCondition.ignore,
    if (request.primaryKey != null)
      // !singular
      'primaryKey': primaryKeyAsList(request.primaryKey),
  });
  return map;
}

Map<String, dynamic> toGetRangeParams(TsGetRangeRequest request) {
  var map = Model({
    'maxVersions': 1,
    'limit': request.limit,
    if (request.tableName != null) 'tableName': request.tableName,
    if (request.columns != null) 'columnsToGet': request.columns,
    if (request.start != null)
      'inclusiveStartPrimaryKey': primaryKeyAsList(request.start.value),
    if (request.end != null)
      'exclusiveEndPrimaryKey': primaryKeyAsList(request.end.value),
    'direction': request.direction ?? TsDirection.forward
  });
  return map;
}

Map<String, dynamic> toStartLocalTransactionParams(
    TsStartLocalTransactionRequest request) {
  var map = Model({
    'tableName': request.tableName,
    // Needed
    'primaryKey': tsPrimaryKeyParams(request.primaryKey),
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
