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

class TsKeyBoundary {
  final TsPrimaryKey value;
  final bool inclusive;

  TsKeyBoundary(this.value, this.inclusive);
}

class TsGetRangeRequest {
  final String tableName;
  TsKeyBoundary start;
  TsKeyBoundary end;
  final List<String> columns;

  TsGetRangeRequest(
      {@required this.tableName,
      this.start,
      this.end,

      /// Optional
      this.columns});
}

// Condition for put and delete
class TsCondition {
  final TsConditionRowExistenceExpectation rowExistenceExpectation;
  final TsColumnCondition columnCondition;

  TsCondition({this.rowExistenceExpectation, this.columnCondition});

  /// Helpers
  static final TsCondition ignore = TsCondition(
      rowExistenceExpectation: TsConditionRowExistenceExpectation.ignore);
  static final TsCondition expectExist = TsCondition(
      rowExistenceExpectation: TsConditionRowExistenceExpectation.expectExist);
  static final TsCondition expectNotExist = TsCondition(
      rowExistenceExpectation:
          TsConditionRowExistenceExpectation.expectNotExist);
}

abstract class TsColumnCondition {
  factory TsColumnCondition.equals(String name, dynamic value) =>
      TsColumnSingleCondition(TsComparatorType.equals, name, value);
  factory TsColumnCondition.or(List<TsColumnCondition> conditions) =>
      TsColumnCompositeCondition(TsLogicalOperator.or, conditions);
  factory TsColumnCondition.and(List<TsColumnCondition> conditions) =>
      TsColumnCompositeCondition(TsLogicalOperator.and, conditions);
}

enum TsComparatorType {
  equals,
  notEquals,
  greaterThan,
  greatorThanOrEquals,
  lessThan,
  lessThanOrEquals,
}

enum TsLogicalOperator {
  and,
  or,
  not,
}

class TsColumnSingleCondition implements TsColumnCondition {
  final TsComparatorType operator;
  final String name;
  final dynamic value;

  TsColumnSingleCondition(this.operator, this.name, this.value);
}

class TsColumnCompositeCondition implements TsColumnCondition {
  final TsLogicalOperator operator;
  final List<TsColumnCondition> list;

  TsColumnCompositeCondition(this.operator, this.list);
}

enum TsConditionRowExistenceExpectation {
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

abstract class TsGetRangeResponse {}

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

extension TsGetRangeResponseExt on TsGetRangeResponse {
  Model toDebugMap() {
    return Model({});
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
