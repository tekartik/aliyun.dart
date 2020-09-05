import 'package:tekartik_aliyun_tablestore/src/ts_column.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/model/model.dart';

class TsGetRowRequest {
  final String tableName;
  final List<TsKeyValue> primaryKeys;
  final List<String> columns;

  TsGetRowRequest(
      {@required this.tableName,
      @required this.primaryKeys,

      /// Optional
      this.columns});
}

class TsCondition {}

class TsPutRowRequest {
  final String tableName;
  final List<TsKeyValue> primaryKeys;
  final TsCondition condition;
  final List<TsAttribute> data;

  TsPutRowRequest(
      {@required this.tableName,
      @required this.primaryKeys,
      this.condition,

      /// Columns values
      this.data});
}

abstract class TsGetRow {
  List<TsKeyValue> get primaryKeys;
  List<TsAttribute> get attributes;
}

abstract class TsGetRowResponse {
  TsGetRow get row;
}

abstract class TsPutRowResponse {
  TsGetRow get row;
}

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

extension TsGetRowResponseRowExt on TsGetRow {
  Model toDebugMap() {
    return Model()
      ..setValue('primaryKeys',
          primaryKeys?.map((e) => e?.toDebugMap())?.toList(growable: false))
      ..setValue('attributes',
          attributes?.map((e) => e?.toDebugMap())?.toList(growable: false));
  }
}
