import 'package:cv/cv.dart';
import 'package:tekartik_aliyun_tablestore/src/ts_column.dart';

class TsGetRowRequest {
  final String tableName;
  final TsPrimaryKey primaryKey;
  final List<String>? columns;

  TsGetRowRequest({
    required this.tableName,
    required this.primaryKey,

    /// Optional
    this.columns,
  });
}

class TsKeyStartBoundary extends TsKeyBoundary {
  TsKeyStartBoundary(TsPrimaryKey value) : super(value, true);
}

class TsKeyEndBoundary extends TsKeyBoundary {
  TsKeyEndBoundary(TsPrimaryKey value) : super(value, false);
}

abstract class TsKeyBoundary {
  final TsPrimaryKey value;
  final bool inclusive;

  TsKeyBoundary(this.value, this.inclusive);
}

class TsGetRangeRequest {
  final String tableName;
  TsPrimaryKey? inclusiveStartPrimaryKey;
  TsPrimaryKey? exclusiveEndPrimaryKey;
  final List<String>? columns;
  final TsDirection? direction;
  final int? limit;
  final TsColumnCondition? columnCondition;

  TsGetRangeRequest({
    required this.tableName,

    /// Optional
    this.inclusiveStartPrimaryKey,
    this.exclusiveEndPrimaryKey,
    this.direction,
    this.limit,
    this.columns,
    this.columnCondition,
  });
}

// Condition for put and delete
class TsCondition {
  final TsConditionRowExistenceExpectation rowExistenceExpectation;
  final TsColumnCondition? columnCondition;

  TsCondition({required this.rowExistenceExpectation, this.columnCondition});

  /// Helpers
  static final TsCondition ignore = TsCondition(
    rowExistenceExpectation: TsConditionRowExistenceExpectation.ignore,
  );
  static final TsCondition expectExist = TsCondition(
    rowExistenceExpectation: TsConditionRowExistenceExpectation.expectExist,
  );
  static final TsCondition expectNotExist = TsCondition(
    rowExistenceExpectation: TsConditionRowExistenceExpectation.expectNotExist,
  );

  Model toDebugMap() {
    return asModel({})
      ..setValue('column', columnCondition?.toDebugMap())
      ..setValue('rowExistence', rowExistenceExpectation);
  }

  @override
  String toString() => toDebugMap().toString();
}

abstract class TsColumnCondition {
  factory TsColumnCondition.equals(String name, dynamic value) =>
      TsColumnSingleCondition(TsComparatorType.equals, name, value);

  factory TsColumnCondition.notEquals(String name, dynamic value) =>
      TsColumnSingleCondition(TsComparatorType.notEquals, name, value);

  factory TsColumnCondition.lessThan(String name, dynamic value) =>
      TsColumnSingleCondition(TsComparatorType.lessThan, name, value);

  factory TsColumnCondition.lessThanOrEquals(String name, dynamic value) =>
      TsColumnSingleCondition(TsComparatorType.lessThanOrEquals, name, value);

  factory TsColumnCondition.greaterThan(String name, dynamic value) =>
      TsColumnSingleCondition(TsComparatorType.greaterThan, name, value);

  factory TsColumnCondition.greaterThanOrEquals(String name, dynamic value) =>
      TsColumnSingleCondition(
        TsComparatorType.greaterThanOrEquals,
        name,
        value,
      );

  factory TsColumnCondition.or(List<TsColumnCondition> conditions) =>
      TsColumnCompositeCondition(TsLogicalOperator.or, conditions);

  factory TsColumnCondition.and(List<TsColumnCondition> conditions) =>
      TsColumnCompositeCondition(TsLogicalOperator.and, conditions);

  Model toDebugMap();
}

enum TsComparatorType {
  equals,
  notEquals,
  greaterThan,
  greaterThanOrEquals,
  lessThan,
  lessThanOrEquals,
}

enum TsDirection { forward, backward }

enum TsLogicalOperator { and, or, not }

class TsColumnSingleCondition implements TsColumnCondition {
  final TsComparatorType operator;
  final String name;
  final dynamic value;

  @override
  Model toDebugMap() =>
      asModel({})
        ..setValue('name', name)
        ..setValue('operator', operator)
        ..setValue('value', value);

  TsColumnSingleCondition(this.operator, this.name, this.value);
}

class TsColumnCompositeCondition implements TsColumnCondition {
  final TsLogicalOperator operator;
  final List<TsColumnCondition> list;

  TsColumnCompositeCondition(this.operator, this.list);

  @override
  Model toDebugMap() =>
      asModel({})
        ..setValue('operator', operator)
        ..setValue(
          'list',
          list.map((e) => e.toDebugMap()).toList(growable: false),
        );
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

  @override
  String toString() => list.toString();

  ModelList toDebugList() =>
      asModelList(list.map((e) => e.toDebugMap()).toList(growable: false));

  Map<String, TsKeyValue> toMap() =>
      list.fold(<String, TsKeyValue>{}, (map, kv) {
        return map..[kv.name] = kv;
      });
}

class TsPutRowRequest {
  final String tableName;
  final TsPrimaryKey primaryKey;
  final TsCondition? condition;
  final TsAttributes data;

  TsPutRowRequest({
    required this.tableName,
    required this.primaryKey,
    this.condition,

    /// Columns values
    required this.data,
  });
}

class TsUpdateRowRequest {
  final String tableName;
  final TsPrimaryKey primaryKey;
  final TsCondition? condition;
  final TsUpdateAttributes data;

  TsUpdateRowRequest({
    required this.tableName,
    required this.primaryKey,
    this.condition,

    /// Columns values
    required this.data,
  });
}

class TsBatchGetRowsRequest {
  final List<TsBatchGetRowsRequestTable> tables;

  TsBatchGetRowsRequest({required this.tables});
}

class TsBatchGetRowsRequestTable {
  final String tableName;
  final List<TsPrimaryKey> primaryKeys;
  final List<String>? columns;

  TsBatchGetRowsRequestTable({
    required this.tableName,
    required this.primaryKeys,

    /// Optional
    this.columns,
  });
}

enum TsWriteRowType { put, update, delete }

class TsBatchWriteRowsRequest {
  final List<TsBatchWriteRowsRequestTable> tables;

  TsBatchWriteRowsRequest({required this.tables});
}

class TsBatchWriteRowsRequestTable {
  final String tableName;
  final List<TsBatchWriteRowsRequestRow> rows;

  TsBatchWriteRowsRequestTable({required this.tableName, required this.rows});
}

class TsBatchWriteRowsRequestDeleteRow extends TsBatchWriteRowsRequestRow {
  TsBatchWriteRowsRequestDeleteRow({required super.primaryKey, super.condition})
    : super(type: TsWriteRowType.delete);
}

class TsBatchWriteRowsRequestUpdateRow extends TsBatchWriteRowsRequestRow {
  TsBatchWriteRowsRequestUpdateRow({
    required super.primaryKey,
    super.condition,
    required this.data,
  }) : super(type: TsWriteRowType.update);
  final TsUpdateAttributes data;
}

class TsBatchWriteRowsRequestPutRow extends TsBatchWriteRowsRequestRow {
  final TsAttributes? data;

  TsBatchWriteRowsRequestPutRow({
    required super.primaryKey,
    super.condition,

    /// Columns values
    this.data,
  }) : super(type: TsWriteRowType.put);
}

abstract class TsBatchWriteRowsRequestRow {
  final TsWriteRowType type;
  final TsPrimaryKey primaryKey;
  final TsCondition? condition;

  TsBatchWriteRowsRequestRow({
    required this.type,
    required this.primaryKey,
    this.condition,
  });
}

class TsDeleteRowRequest {
  final String tableName;
  final TsPrimaryKey primaryKey;
  final TsCondition? condition;

  TsDeleteRowRequest({
    required this.tableName,
    required this.primaryKey,

    /// Optional
    this.condition,
  });
}

abstract class TsGetRow {
  bool get exists;

  /// Null if the record was not found
  TsPrimaryKey? get primaryKey;

  TsAttributes? get attributes;
}

abstract class TsGetRowResponse {
  TsGetRow get row;
}

abstract class TsPutRowResponse {
  TsGetRow get row;
}

abstract class TsUpdateRowResponse {
  TsGetRow get row;
}

abstract class TsDeleteRowResponse {}

abstract class TsGetRangeResponse {
  List<TsGetRow> get rows;

  TsPrimaryKey? get nextStartPrimaryKey;
}

// {isOk: true, errorCode: null, errorMessage: null, tableName: test_key_string,
// capacityUnit: {read: 1, write: 0}, primaryKey: [{name: key, value: batch_1}],
// attributes: [{columnName: test, columnValue: {buffer: [1, 0, 0, 0, 0, 0, 0, 0], offset: 0}
abstract class TsBatchGetRowsResponseRow {
  bool get isOk;

  /// if error
  String? get errorCode;

  /// if error
  String? get errorMessage;

  /// if no error
  String get tableName;

  /// if no error
  TsPrimaryKey? get primaryKey;

  /// if no error
  TsAttributes? get attributes;
}

abstract class TsBatchGetRowsResponse {
  List<List<TsBatchGetRowsResponseRow>> get tables;
}

abstract class TsBatchWriteRowsResponse {
  List<TsBatchGetRowsResponseRow> get rows;
}

extension TsGetRowResponseExt on TsGetRowResponse {
  Model toDebugMap() {
    return asModel({})..setValue('row', row.toDebugMap());
  }
}

extension TsPutRowResponseExt on TsPutRowResponse {
  Model toDebugMap() {
    return asModel({})..setValue('row', row.toDebugMap());
  }
}

extension TsUpdateRowResponseExt on TsUpdateRowResponse {
  Model toDebugMap() {
    return asModel({})..setValue('row', row.toDebugMap());
  }
}

extension TsStartLocalTransactionResponseExt
    on TsStartLocalTransactionResponse {
  Model toDebugMap() {
    return asModel({})..setValue('transactionId', transactionId);
  }
}

extension TsGetRangeResponseExt on TsGetRangeResponse {
  Model toDebugMap() {
    return asModel({})
      ..setValue('rows', rows.map((row) => row.toDebugMap()))
      ..setValue('nextStartPrimaryKey', nextStartPrimaryKey?.toDebugList());
    //return asModel({})..setValue('rows', rows?.map((row) => row.toDebugMap()));
  }
}

extension TsBatchGetRowsResponseExt on TsBatchGetRowsResponse {
  Model toDebugMap() {
    return asModel({})..setValue(
      'tables',
      tables
          .map(
            (table) =>
                table.map((row) => row.toDebugMap()).toList(growable: false),
          )
          .toList(growable: false),
    );
  }
}

extension TsBatchWriteRowsResponseExt on TsBatchWriteRowsResponse {
  Model toDebugMap() {
    return asModel({})..setValue(
      'rows',
      rows.map((row) => row.toDebugMap()).toList(growable: false),
    );
  }
}

extension TsBatchGetRowsResponseRowExt on TsBatchGetRowsResponseRow {
  Model toDebugMap() {
    return asModel({})
      ..setValue('isOk', isOk)
      ..setValue('errorMessage', errorMessage)
      ..setValue('errorCode', errorCode)
      ..setValue('tableName', tableName)
      ..setValue('primaryKey', primaryKey?.toDebugList())
      ..setValue('attributes', attributes?.toDebugList());
  }
}

extension TsDeleteRowResponseExt on TsDeleteRowResponse {
  Model toDebugMap() {
    return asModel({});
  }
}

extension TsGetRowExt on TsGetRow {
  Model toDebugMap() {
    return asModel({})
      ..setValue('primaryKey', primaryKey?.toDebugList())
      ..setValue('attributes', attributes?.toDebugList());
  }
}

class TsStartLocalTransactionRequest {
  final String tableName;
  final TsPrimaryKey primaryKey;

  // Primary key must contain only the partition key (i.e. single key value
  TsStartLocalTransactionRequest({
    required this.tableName,
    required this.primaryKey,
  });
}

abstract class TsStartLocalTransactionResponse {
  dynamic get transactionId;
}
