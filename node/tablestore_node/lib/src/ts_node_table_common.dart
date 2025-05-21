import 'package:cv/cv.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_tablestore_common.dart';

Map<String, dynamic> toCreateTableParams(TsTableDescription description) {
  var map = asModel({
    if (description.tableMeta != null)
      'tableMeta': {
        'tableName': description.tableMeta!.tableName,
        // TsArrayHack needed
        'primaryKey': TsArrayHack(
          description.tableMeta!.primaryKeys!.map((item) {
            return {
              'name': item.name,
              'type': columnTypeToNativeType(item.type),
            };
          }),
        ),
      },
    if (description.reservedThroughput != null)
      'reservedThroughput': description.reservedThroughput!.toMap(),
    if (description.tableOptions != null)
      'tableOptions': description.tableOptions!.toMap(),
  });
  return map;
}

TsColumnType nativeTypeToColumnType(int type) {
  if (type == tsNodeCommon.primaryKeyType.INTEGER) {
    return TsColumnType.integer;
  } else if (type == tsNodeCommon.primaryKeyType.STRING) {
    return TsColumnType.string;
  } else if (type == tsNodeCommon.primaryKeyType.BINARY) {
    return TsColumnType.binary;
  }
  throw 'type $type not supported';
}

int columnTypeToNativeType(TsColumnType? type) {
  if (type == TsColumnType.integer) {
    return tsNodeCommon.primaryKeyType.INTEGER;
  } else if (type == TsColumnType.string) {
    return tsNodeCommon.primaryKeyType.STRING;
  } else if (type == TsColumnType.binary) {
    return tsNodeCommon.primaryKeyType.BINARY;
  }
  throw 'type $type not supported';
}
