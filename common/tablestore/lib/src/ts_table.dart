import 'package:cv/cv.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

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

TsColumnType? _columnTypeFromText(String? text) {
  for (var type in _columnTypes) {
    if (text == enumText(type)) {
      return type;
    }
  }
  return null;
}

class TsPrimaryKeyDef {
  final String? name;
  final TsColumnType? type;

  // integer only
  final bool? autoIncrement;

  TsPrimaryKeyDef({this.name, this.type, this.autoIncrement});

  @override
  String toString() => 'pk($name, ${enumText(type)})';

  Model toMap() {
    var map = asModel({
      if (name != null) 'name': name,
      if (type != null) 'type': enumText(type),
      if (autoIncrement ?? false) 'autoIncrement': true
    });
    return map;
  }

  factory TsPrimaryKeyDef.fromMap(Map? map) {
    var model = asModel(map ?? {});
    var name = model.getValue('name')?.toString();
    var type = _columnTypeFromText(model.getValue('type')?.toString());
    var autoIncrement = parseBool(model.getValue('autoIncrement'));
    return TsPrimaryKeyDef(
        name: name, type: type, autoIncrement: autoIncrement);
  }
}

class TsTableDescriptionTableMeta {
  final String? tableName;
  List<TsPrimaryKeyDef>? primaryKeys;

  TsTableDescriptionTableMeta({this.tableName, this.primaryKeys});

  Model toMap() {
    var map = asModel({
      'name': tableName,
      if (primaryKeys != null)
        'primaryKeys':
            primaryKeys!.map((key) => key.toMap()).toList(growable: false)
    });
    return map;
  }

  factory TsTableDescriptionTableMeta.fromMap(Map map) {
    var model = asModel(map);
    var tableName = model.getValue('name')?.toString();
    List<TsPrimaryKeyDef>? primaryKeys;
    var rawPrimaryKeys = model.getValue('primaryKeys');
    if (rawPrimaryKeys is List) {
      primaryKeys = rawPrimaryKeys
          .map((raw) => TsPrimaryKeyDef.fromMap(asModel(raw as Map)))
          .toList(growable: false);
    }
    return TsTableDescriptionTableMeta(
        tableName: tableName, primaryKeys: primaryKeys);
  }
}

class TsTableDescriptionReservedThroughput {
  final TsTableCapacityUnit? capacityUnit;

  TsTableDescriptionReservedThroughput({this.capacityUnit});

  Model toMap() {
    var map = asModel(
        {if (capacityUnit != null) 'capacityUnit': capacityUnit!.toMap()});
    return map;
  }

  factory TsTableDescriptionReservedThroughput.fromMap(Map map) {
    var model = asModel(map);
    TsTableCapacityUnit? capacityUnit;
    var rawCapacityUnit = model.getValue('capacityUnit');
    if (rawCapacityUnit is Map) {
      capacityUnit = TsTableCapacityUnit.fromMap(rawCapacityUnit);
    }
    return TsTableDescriptionReservedThroughput(capacityUnit: capacityUnit);
  }
}

class TsTableCapacityUnit {
  final int? read;
  final int? write;

  TsTableCapacityUnit({this.read, this.write});

  Model toMap() {
    var map = asModel(
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
  final int? timeToLive;
  final int? maxVersions;

  TsTableDescriptionOptions({this.timeToLive, this.maxVersions});

  Model toMap() {
    var map = asModel({
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
  final TsTableDescriptionTableMeta? tableMeta;

  // In/Out
  final TsTableDescriptionReservedThroughput? reservedThroughput;

  // In/Out
  final TsTableDescriptionOptions? tableOptions;

  TsTableDescription(
      {this.tableMeta, this.reservedThroughput, this.tableOptions});

  @override
  String toString() =>
      'name ${tableMeta!.tableName}, primaryKeys: ${tableMeta!.primaryKeys}';

  Model toMap() {
    var map = asModel({
      if (tableMeta != null) 'tableMeta': tableMeta!.toMap(),
      if (reservedThroughput != null)
        'reservedThroughput': reservedThroughput!.toMap(),
      if (tableOptions != null) 'tableOptions': tableOptions!.toMap()
    });
    return map;
  }

  factory TsTableDescription.fromMap(Map map) {
    var model = asModel(map);
    TsTableDescriptionTableMeta? tableMeta;
    var rawTableMeta = model.getValue('tableMeta');
    if (rawTableMeta is Map) {
      tableMeta = TsTableDescriptionTableMeta.fromMap(rawTableMeta);
    }
    TsTableDescriptionOptions? tableOptions;
    var rawOptions = model.getValue('tableOptions');
    if (rawOptions is Map) {
      tableOptions = TsTableDescriptionOptions.fromMap(rawOptions);
    }
    TsTableDescriptionReservedThroughput? reservedThroughput;
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
