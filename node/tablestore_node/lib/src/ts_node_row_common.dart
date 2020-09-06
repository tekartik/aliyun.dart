import 'package:tekartik_aliyun_tablestore/tablestore.dart';
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

int tsConditionToNative(TsCondition condition) {
  switch (condition) {
    case TsCondition.ignore:
      return tsNodeCommon.rowExistenceExpectation.IGNORE;
    case TsCondition.expectExist:
      return tsNodeCommon.rowExistenceExpectation.EXPECT_EXIST;
    case TsCondition.expectNotExist:
      return tsNodeCommon.rowExistenceExpectation.EXPECT_NOT_EXIST;
  }
  throw 'condition $condition not supported';
}
