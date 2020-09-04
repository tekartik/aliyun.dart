import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_common_utils/model/model.dart';

Map<String, dynamic> toCreateTableParams(TsTableDescription description) {
  var map = Model({
    if (description.tableMeta != null)
      'tableMeta': {
        'tableName': description.tableMeta.tableName,
        // !singular
        'primaryKey': description.tableMeta.primaryKeys.map((item) {
          return {'name': item.name, 'type': colunTypeToNativeType(item.type)};
        })
      },
    if (description.reservedThroughput != null)
      'reservedThroughput': description.reservedThroughput.toMap(),
    if (description.tableOptions != null)
      'tableOptions': description.tableOptions.toMap()
  });
  return map;
}

TsColumnType nativeTypeToColumnType(int type) {
  if (type == 1) {
    return TsColumnType.integer;
  } else if (type == 2) {
    return TsColumnType.string;
  } else if (type == 3) {
    return TsColumnType.binary;
  }
  throw 'type $type not supported';
}

int colunTypeToNativeType(TsColumnType type) {
  if (type == TsColumnType.integer) {
    return 1;
  } else if (type == TsColumnType.string) {
    return 2;
  } else if (type == TsColumnType.binary) {
    return 3;
  }
  throw 'type $type not supported';
}
