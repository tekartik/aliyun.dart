import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_tablestore_common.dart';
import 'package:tekartik_common_utils/model/model.dart';

Map<String, dynamic> toPrimaryKeyValueParam(TsKeyValue keyValue) =>
    <String, dynamic>{keyValue.name: keyValue.value};

Map<String, dynamic> toGetRowParams(TsGetRowRequest getRowRequest) {
  var map = Model({
    if (getRowRequest.tableName != null) 'tableName': getRowRequest.tableName,
    if (getRowRequest.primaryKeys != null)
      // !singular
      'primaryKey': getRowRequest.primaryKeys
          .map(toPrimaryKeyValueParam)
          .toList(growable: false),
    if (getRowRequest.columns != null) 'columnsToGet': getRowRequest.columns,
  });
  return map;
}

Map<String, dynamic> toPutRowParams(TsPutRowRequest getRowRequest) {
  var map = Model({
    if (getRowRequest.tableName != null) 'tableName': getRowRequest.tableName,
    //TODO fix
    // Needed
    'condition': TsCondition(),
    if (getRowRequest.primaryKeys != null)
      // !singular
      'primaryKey': getRowRequest.primaryKeys
          .map(toPrimaryKeyValueParam)
          .toList(growable: false),
    if (getRowRequest.data != null) 'attributeColumns': [getRowRequest.data],
    'returnContent': {'returnType': tsNodeCommon.returnType.Primarykey}
  });
  return map;
}
