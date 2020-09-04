@JS()
library tekartik_aliyun_tablestore_node.ts_table_interop;

import 'package:js/js.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

import 'ts_interop.dart';

@JS()
@anonymous
// // Key types: {INTEGER: 1, STRING: 2, BINARY: 3}
abstract class PrimaryKeyTypeJs {
  external int get INTEGER;

  external int get STRING;

  external int get BINARY;
}

@JS()
@anonymous
class TsClientListTableParamsJs {}

@JS()
@anonymous
class TsClientTableParamsJs {
  external factory TsClientTableParamsJs({String tableName});
}

/*
var params = {
  tableMeta: {
    tableName: 'sampleTable',
    primaryKey: [
      {
        name: 'gid',
        type: 'INTEGER'
      },
      {
        name: 'uid',
        type: 'INTEGER'
      }
    ]
  },
  reservedThroughput: {
    capacityUnit: {
      read: 0,
      write: 0
    }
  },
  tableOptions: {
    timeToLive: -1,// 数据的过期时间, 单位秒, -1代表永不过期. 假如设置过期时间为一年, 即为 365 * 24 * 3600.
    maxVersions: 1// 保存的最大版本数, 设置为1即代表每列上最多保存一个版本(保存最新的版本).
  },
  streamSpecification: {
    enableStream: true, //开启Stream
    expirationTime: 24 //Stream的过期时间，单位是小时，最长为168，设置完以后不能修改
  }
};

@JS()
@anonymous
class _TsClientCreateTableParamsJs {
  external String get tableName;
  external set tableName(String tableName);
  external factory _TsClientDeleteTableParamsJs({String tableName});
}
*/

@JS()
@anonymous
class _TsTableJs {}

class TsTableNode implements TsTable {
  final _TsTableJs native;

  TsTableNode(this.native);
}

@JS()
@anonymous
abstract class TsClientListTableResponseJs {
  List<String> get tableNames;
}

//     "primaryKey": [
//       {
//         "name": "gid",
//         "type": 1
//       },
@JS()
@anonymous
abstract class _TsClientPrimaryKey {
  external String get name;

  external int get type;
}

//   "tableMeta": {
//     "primaryKey": [
//       {
//         "name": "gid",
//         "type": 1
//       },
//       {
//         "name": "uid",
//         "type": 1
//       }
//     ],
//     "definedColumn": [],
//     "indexMeta": [],
//     "tableName": "test_create1"
//   },
@JS()
@anonymous
abstract class _TsClientTableDescriptionTableMetaJs {
  external String get tableName;

  external List<dynamic /*_TsClientPrimaryKey*/ > get primaryKey;
}

@JS()
@anonymous
abstract class _TsClientTableDescriptionTableOptionsJs {
  external int get timeToLive;

  external int get maxVersions;
}

@JS()
@anonymous
abstract class _TsClientTableDescriptionReservedThroughputJs {
  external _TsClientTableDescriptionCapacityUnit get capacityUnit;
}

@JS()
@anonymous
abstract class _TsClientTableDescriptionCapacityUnit {
  external int get read;

  external int get write;
}

List<_TsClientPrimaryKey> tableMetaPrimaryKeys(
        _TsClientTableDescriptionTableMetaJs tableMeta) =>
    tableMeta.primaryKey.cast<_TsClientPrimaryKey>().toList(growable: false);

// {
//   "shardSplits": [],
//   "indexMetas": [],
//   "tableMeta": {
//     "primaryKey": [
//       {
//         "name": "gid",
//         "type": 1
//       },
//       {
//         "name": "uid",
//         "type": 1
//       }
//     ],
//     "definedColumn": [],
//     "indexMeta": [],
//     "tableName": "test_create1"
//   },
//   "reservedThroughputDetails": {
//     "capacityUnit": {
//       "read": 0,
//       "write": 0
//     },
//     "lastIncreaseTime": {
//       "low": 1599074982,
//       "high": 0,
//       "unsigned": false
//     }
//   },
//   "tableOptions": {
//     "timeToLive": -1,
//     "maxVersions": 1,
//     "deviationCellVersionInSec": {
//       "low": 86400,
//       "high": 0,
//       "unsigned": false
//     }
//   },
//   "tableStatus": 1,
//   "streamDetails": {
//     "enableStream": true,
//     "streamId": "test_create1_1599074982214249",
//     "expirationTime": 24,
//     "lastEnableTime": {
//       "low": -1471628695,
//       "high": 372313,
//       "unsigned": false
//     }
//   },
//   "RequestId": "0005ae6f-af63-250c-a4c1-720b08797701"
// }
// Response only
@JS()
@anonymous
abstract class _TsClientTableDescriptionJs {
  external _TsClientTableDescriptionTableMetaJs get tableMeta;
  external _TsClientTableDescriptionReservedThroughputJs
      get reservedThroughputDetails;
  external _TsClientTableDescriptionTableOptionsJs get tableOptions;
}

TsColumnType nativeTypeToColumnType(int type) {
  if (type == tablestoreJs.PrimaryKeyType.INTEGER) {
    return TsColumnType.integer;
  } else if (type == tablestoreJs.PrimaryKeyType.STRING) {
    return TsColumnType.string;
  } else if (type == tablestoreJs.PrimaryKeyType.BINARY) {
    return TsColumnType.binary;
  }
  throw 'type $type not supported';
}

TsTableDescription tableDescriptionFromNative(dynamic nativeDesc) {
  if (nativeDesc != null) {
    var nativeDescObject = nativeDesc as _TsClientTableDescriptionJs;
    var nativeTableMeta = nativeDescObject.tableMeta;
    var nativeTableOptions = nativeDescObject.tableOptions;
    var nativeReservedThroughput = nativeDescObject.reservedThroughputDetails;
    TsTableDescriptionTableMeta tableMeta;
    TsTableDescriptionOptions tableOptions;
    TsTableDescriptionReservedThroughput reservedThroughPut;
    if (nativeTableMeta != null) {
      List<TsPrimaryKey> primaryKeys;
      var nativePrimaryKeys = tableMetaPrimaryKeys(nativeTableMeta);
      if (nativePrimaryKeys != null) {
        primaryKeys = <TsPrimaryKey>[];
        nativePrimaryKeys.forEach((element) {
          primaryKeys.add(TsPrimaryKey(
              type: nativeTypeToColumnType(element.type), name: element.name));
        });
      }
      tableMeta = TsTableDescriptionTableMeta(
          tableName: nativeTableMeta.tableName, primaryKeys: primaryKeys);
    }
    if (nativeTableOptions != null) {
      tableOptions = TsTableDescriptionOptions(
          timeToLive: nativeTableOptions.timeToLive,
          maxVersions: nativeTableOptions.maxVersions);
    }
    if (nativeReservedThroughput != null) {
      TsTableCapacityUnit capacityUnit;
      if (nativeReservedThroughput.capacityUnit != null) {
        capacityUnit = TsTableCapacityUnit(
            write: nativeReservedThroughput.capacityUnit.write,
            read: nativeReservedThroughput.capacityUnit.read);
      }
      reservedThroughPut =
          TsTableDescriptionReservedThroughput(capacityUnit: capacityUnit);
    }

    return TsTableDescription(
        tableMeta: tableMeta,
        tableOptions: tableOptions,
        reservedThroughput: reservedThroughPut);
//

  }
  return null;
}

List<String> tableNamesFromNative(TsClientListTableResponseJs native) {
  return List<String>.from(native.tableNames);
}
