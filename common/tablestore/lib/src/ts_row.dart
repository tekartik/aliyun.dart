import 'package:tekartik_aliyun_tablestore/src/ts_column.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/model/model.dart';

class TsGetRowRequest {
  final String tableName;
  final TsPrimaryKey primaryKey;
  final List<String> columns;

  TsGetRowRequest(
      {@required this.tableName,
      @required this.primaryKey,

      /// Optional
      this.columns});
}

// Condition for put and delete
enum TsCondition {
  ignore, // Upsert
  expectExist, // Update
  expectNotExist, // Add
}

/// Primary key
class TsPrimaryKey {
  final List<TsKeyValue> list;

  TsPrimaryKey(this.list);
}

class TsPutRowRequest {
  final String tableName;
  final TsPrimaryKey primaryKey;
  final TsCondition condition;
  final List<TsAttribute> data;

  TsPutRowRequest(
      {@required this.tableName,
      @required this.primaryKey,
      this.condition,

      /// Columns values
      this.data});
}

class TsDeleteRowRequest {
  final String tableName;
  final TsPrimaryKey primaryKey;
  final TsCondition condition;

  TsDeleteRowRequest(
      {@required this.tableName,
      @required this.primaryKey,

      /// Optional
      this.condition});
}

abstract class TsGetRow {
  TsPrimaryKey get primaryKey;
  List<TsAttribute> get attributes;
}

abstract class TsGetRowResponse {
  TsGetRow get row;
}

abstract class TsPutRowResponse {
  TsGetRow get row;
}

abstract class TsDeleteRowResponse {}

extension TsGetRowResponseExt on TsGetRowResponse {
  Model toDebugMap() {
    return Model({})..setValue('row', row?.toDebugMap());
  }
}

extension TsPutRowResponseExt on TsPutRowResponse {
  Model toDebugMap() {
    return Model({})..setValue('row', row?.toDebugMap());
  }
}

extension TsDeleteRowResponseExt on TsDeleteRowResponse {
  Model toDebugMap() {
    return Model({});
  }
}

extension TsGetRowResponseRowExt on TsGetRow {
  Model toDebugMap() {
    return Model()
      ..setValue('primaryKeys',
          primaryKey.list?.map((e) => e?.toDebugMap())?.toList(growable: false))
      ..setValue('attributes',
          attributes?.map((e) => e?.toDebugMap())?.toList(growable: false));
  }
}
