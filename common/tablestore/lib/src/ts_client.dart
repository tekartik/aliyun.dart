import 'package:meta/meta.dart';
import 'package:tekartik_aliyun_tablestore/src/ts_row.dart';
import 'package:tekartik_common_utils/bool_utils.dart';
import 'package:tekartik_common_utils/int_utils.dart';
import 'package:tekartik_common_utils/model/model.dart';

/// Table store exception
class TsException implements Exception {
  final String message;

  TsException(this.message);
}

/// Client options
class TsClientOptions {
  /// Aliyun access key id
  final String accessKeyId;

  /// Aliyun secret
  final String secretAccessKey;

  /// Table store endpoint
  final String endpoint;

  /// Table store instance name
  final String instanceName;

  TsClientOptions(
      {@required this.accessKeyId,
      @required this.secretAccessKey,
      @required this.endpoint,
      this.instanceName});

  @override
  String toString() {
    return {'endpoint': endpoint}.toString();
  }
}

enum TsColumnType {
  integer,
  string,
  binary,
}

var _columnTypes = [
  TsColumnType.integer,
  TsColumnType.string,
  TsColumnType.binary
];
String enumText(dynamic value) => value.toString().split('.').last;
TsColumnType _columnTypeFromText(String text) {
  for (var type in _columnTypes) {
    if (text == enumText(type)) {
      return type;
    }
  }
  return null;
}

class TsPrimaryKey {
  final String name;
  final TsColumnType type;
  // integer only
  final bool autoIncrement;

  TsPrimaryKey({this.name, this.type, this.autoIncrement});

  @override
  String toString() => 'pk($name, ${enumText(type)})';

  Model toMap() {
    var map = Model({
      if (name != null) 'name': name,
      if (type != null) 'type': enumText(type),
      if (autoIncrement ?? false) 'autoIncrement': true
    });
    return map;
  }

  factory TsPrimaryKey.fromMap(Map map) {
    var model = Model(map);
    var name = model.getValue('name')?.toString();
    var type = _columnTypeFromText(model.getValue('type')?.toString());
    var autoIncrement = parseBool(model.getValue('autoIncrement'));
    return TsPrimaryKey(name: name, type: type, autoIncrement: autoIncrement);
  }
}

class TsTableDescriptionTableMeta {
  final String tableName;
  List<TsPrimaryKey> primaryKeys;

  TsTableDescriptionTableMeta({this.tableName, this.primaryKeys});

  Model toMap() {
    var map = Model({
      'name': tableName,
      if (primaryKeys != null)
        'primaryKeys':
            primaryKeys.map((key) => key.toMap()).toList(growable: false)
    });
    return map;
  }

  factory TsTableDescriptionTableMeta.fromMap(Map map) {
    var model = Model(map);
    var tableName = model.getValue('name')?.toString();
    List<TsPrimaryKey> primaryKeys;
    var rawPrimaryKeys = model.getValue('primaryKeys');
    if (rawPrimaryKeys is List) {
      primaryKeys = rawPrimaryKeys
          .map((raw) => TsPrimaryKey.fromMap(asModel(raw)))
          .toList(growable: false);
    }
    return TsTableDescriptionTableMeta(
        tableName: tableName, primaryKeys: primaryKeys);
  }
}

class TsTableDescriptionReservedThroughput {
  final TsTableCapacityUnit capacityUnit;

  TsTableDescriptionReservedThroughput({this.capacityUnit});

  Model toMap() {
    var map =
        Model({if (capacityUnit != null) 'capacityUnit': capacityUnit.toMap()});
    return map;
  }

  factory TsTableDescriptionReservedThroughput.fromMap(Map map) {
    var model = Model(map);
    TsTableCapacityUnit capacityUnit;
    var rawCapacityUnit = model.getValue('capacityUnit');
    if (rawCapacityUnit is Map) {
      capacityUnit = TsTableCapacityUnit.fromMap(rawCapacityUnit);
    }
    return TsTableDescriptionReservedThroughput(capacityUnit: capacityUnit);
  }
}

class TsTableCapacityUnit {
  final int read;
  final int write;

  TsTableCapacityUnit({this.read, this.write});

  Model toMap() {
    var map = Model(
        {if (read != null) 'read': read, if (write != null) 'write': write});
    return map;
  }

  factory TsTableCapacityUnit.fromMap(Map map) {
    var read = parseInt(map['read']);
    var write = parseInt(map['write']);

    return TsTableCapacityUnit(read: read, write: write);
  }
}

class TsTableDescriptionOptions {
  final int timeToLive;
  final int maxVersions;

  TsTableDescriptionOptions({this.timeToLive, this.maxVersions});

  Model toMap() {
    var map = Model({
      if (timeToLive != null) 'timeToLive': timeToLive,
      if (maxVersions != null) 'maxVersions': maxVersions
    });
    return map;
  }

  factory TsTableDescriptionOptions.fromMap(Map map) {
    var timeToLive = parseInt(map['timeToLive']);
    var maxVersions = parseInt(map['maxVersions']);

    return TsTableDescriptionOptions(
        timeToLive: timeToLive, maxVersions: maxVersions);
  }
}

var tableCreateCapacityUnitDefault = TsTableCapacityUnit(read: 0, write: 0);
var tableCreateReservedThroughputDefault = TsTableDescriptionReservedThroughput(
    capacityUnit: tableCreateCapacityUnitDefault);
var tableCreateOptionsDefault =
    TsTableDescriptionOptions(maxVersions: 1, timeToLive: -1);

// reservedThroughput: {
//     capacityUnit: {
//       read: 0,
//       write: 0
//     }
//   },
//   tableOptions: {
//     timeToLive: -1,// 数据的过期时间, 单位秒, -1代表永不过期. 假如设置过期时间为一年, 即为 365 * 24 * 3600.
//     maxVersions: 1// 保存的最大版本数, 设置为1即代表每列上最多保存一个版本(保存最新的版本).
//   }
// In/Out
class TsTableDescription {
  // In/Out
  final TsTableDescriptionTableMeta tableMeta;
  // In/Out
  final TsTableDescriptionReservedThroughput reservedThroughput;
  // In/Out
  final TsTableDescriptionOptions tableOptions;

  TsTableDescription(
      {this.tableMeta, this.reservedThroughput, this.tableOptions});

  @override
  String toString() =>
      'name ${tableMeta.tableName}, primaryKeys: ${tableMeta.primaryKeys}';

  Model toMap() {
    var map = Model({
      if (tableMeta != null) 'tableMeta': tableMeta.toMap(),
      if (reservedThroughput != null)
        'reservedThroughput': reservedThroughput.toMap(),
      if (tableOptions != null) 'tableOptions': tableOptions.toMap()
    });
    return map;
  }

  factory TsTableDescription.fromMap(Map map) {
    var model = Model(map);
    TsTableDescriptionTableMeta tableMeta;
    var rawTableMeta = model.getValue('tableMeta');
    if (rawTableMeta is Map) {
      tableMeta = TsTableDescriptionTableMeta.fromMap(rawTableMeta);
    }
    TsTableDescriptionOptions tableOptions;
    var rawOptions = model.getValue('tableOptions');
    if (rawOptions is Map) {
      tableOptions = TsTableDescriptionOptions.fromMap(rawOptions);
    }
    TsTableDescriptionReservedThroughput reservedThroughput;
    var rawReservedThroughput = model.getValue('reservedThroughput');
    if (rawReservedThroughput is Map) {
      reservedThroughput =
          TsTableDescriptionReservedThroughput.fromMap(rawReservedThroughput);
    }
    return TsTableDescription(
        tableMeta: tableMeta,
        tableOptions: tableOptions,
        reservedThroughput: reservedThroughput);
  }
}

abstract class TsClient {
  Future<List<String>> listTableNames();
  Future deleteTable(String name);

  Future createTable(String tableName, TsTableDescription description);

  Future<TsTableDescription> describeTable(String tableName);

  Future<TsPutRowResponse> putRow(TsPutRowRequest request);
  Future<TsGetRowResponse> getRow(TsGetRowRequest request);
}

mixin TsClientMixin implements TsClient {
  @override
  Future<List<String>> listTableNames() =>
      throw UnsupportedError('listTableNames');
}
