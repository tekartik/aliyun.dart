import 'package:tekartik_aliyun_tablestore/src/ts_client.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/model/model.dart';

class TsGetRowRequest {
  final String tableName;
  final List<TsPrimaryKeyValue> primaryKeys;
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
  final List<TsPrimaryKeyValue> primaryKeys;
  final TsCondition condition;
  final Map<String, dynamic> data;

  TsPutRowRequest(
      {@required this.tableName,
      @required this.primaryKeys,
      this.condition,

      /// Columns values
      this.data});
}

class TsRow {
  Model toMap() {
    return Model({});
  }
}

abstract class TsGetRowResponse {
  TsRow row;
}

abstract class TsPutRowResponse {
  TsRow get row;

  Model toMap() {
    return Model({if (row != null) 'row': row.toMap()});
  }

  @override
  String toString() => toMap().toString();
}
