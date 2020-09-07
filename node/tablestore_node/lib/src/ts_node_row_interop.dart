@JS()
library tekartik_aliyun_tablestore_node.ts_row_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/import.dart';
import 'package:tekartik_aliyun_tablestore_node/src/interop/utils_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_common.dart';

// ignore_for_file: non_constant_identifier_names
@JS()
@anonymous
abstract class TsRowExistenceExpectationJs
    implements TsConstantRowExistenceExpectation {
  @override
  external int get IGNORE;

  @override
  external int get EXPECT_EXIST;

  @override
  external int get EXPECT_NOT_EXIST;
}

@JS()
@anonymous
abstract class TsConstantComparatorTypeJs implements TsConstantComparatorType {
  @override
  external int get EQUAL;
  @override
  external int get NOT_EQUAL;
  @override
  external int get GREATER_THAN;
  @override
  external int get GREATER_EQUAL;
  @override
  external int get LESS_THAN;
  @override
  external int get LESS_EQUAL;
}

@JS()
@anonymous
abstract class TsConstantLogicalOperatorJs
    implements TsConstantLogicalOperator {
  @override
  external int get AND;

  @override
  external int get NOT;

  @override
  external int get OR;
}

@JS()
@anonymous
abstract class TsReturnTypeJs implements TsConstantReturnType {
  @override
  external int get AfterModify;

  @override
  external int get NONE;

  @override
  external int get Primarykey;
}

@JS()
@anonymous
abstract class TsLongJs implements TsNodeLong {
  @override
  external int toNumber();

  @override
  external String toString();
}

@JS()
@anonymous
abstract class TsNodeLongClassJs implements TsNodeLongClass {
  @override
  external TsLongJs fromNumber(int value);

  @override
  external TsLongJs fromString(String value);
}

class TsNodeLongClassImpl implements TsNodeLongClass {
  @override
  TsNodeLong fromNumber(int value) {
    return tablestoreJs.Long.fromNumber(value);
  }

  @override
  TsNodeLong fromString(String value) {
    return tablestoreJs.Long.fromString(value);
  }
}

@JS()
@anonymous
class TsRowPrimaryKeyValueJs {
  external String get name;

  external dynamic get value;
}

@JS()
@anonymous
class TsRowAttributeKeyValueJs {
  external String get columnName;

  external dynamic get columnValue;
}

class TsGetRowParamsJs {}

class TsPutRowParamsJs {}

//
// Put Row
//
/*

{
  "consumed": {
    "capacityUnit": {
      "read": 0,
      "write": 1
    }
  },
  "row": {
    "primaryKey": [
      {
        "name": "key",
        "value": "value"
      }
    ],
    "attributes": []
  },
  "RequestId": "0005ae92-7cca-c9e0-a5c1-720b0c8f1830"
}
 */

// Response to native
TsPutRowResponse putRowResponseFromNative(dynamic nativeResponseJs) {
  if (nativeResponseJs != null) {
    return TsPutRowResponseNode(nativeResponseJs as TsReadRowResponseJs);
  }
  return null;
}

// Response to native
TsDeleteRowResponse deleteRowResponseFromNative(dynamic nativeResponseJs) {
  if (nativeResponseJs != null) {
    return TsDeleteRowResponseNode();
  }
  return null;
}

//
// Get Row
//
/*
{
  "consumed": {
    "capacityUnit": {
      "read": 1,
      "write": 0
    }
  },
  "row": {
    "primaryKey": [
      {
        "name": "key",
        "value": "value"
      }
    ],
    "attributes": [
      {
        "columnName": "test",
        "columnValue": "text",
        "timestamp": {
          "buffer": [
            30,
            20,
            154,
            94,
            116,
            1,
            0,
            0
          ],
          "offset": 0
        }
      }
    ]
  },
  "RequestId": "0005ae91-b111-0dc7-2bc1-720b0b7a5163"
}
 */
@JS()
@anonymous
class TsReadRowResponseJs {
  external TsReadRowJs get row;
}

@JS()
@anonymous
class TsReadRowJs {
  external List get primaryKey;

  external List get attributes;
}

Iterable<TsRowPrimaryKeyValueJs> rowPrimaryKeyValuesJs(TsReadRowJs js) =>
    js.primaryKey.map((e) => e as TsRowPrimaryKeyValueJs);

Iterable<TsRowAttributeKeyValueJs> rowAttributeKeyValuesJs(TsReadRowJs js) =>
    js.attributes.map((e) => e as TsRowAttributeKeyValueJs);

// Response to native
TsGetRowResponse getRowResponseFromNative(dynamic nativeResponseJs) {
  if (nativeResponseJs != null) {
    return TsGetRowResponseNode(nativeResponseJs as TsReadRowResponseJs);
  }
  return null;
}

class TsGetRowNode implements TsGetRow {
  final TsReadRowJs rowJs;

  TsGetRowNode(this.rowJs);

  @override
  TsPrimaryKey get primaryKey =>
      TsPrimaryKey(rowPrimaryKeyValuesJs(rowJs).map((kvJs) {
        return TsKeyValue(kvJs.name, tsDartifyValue(kvJs.value));
      }).toList());

  @override
  List<TsAttribute> get attributes =>
      rowAttributeKeyValuesJs(rowJs).map((kvJs) {
        return TsAttribute(kvJs.columnName, tsDartifyValue(kvJs.columnValue));
      }).toList();
}

abstract class TsReadRowResponseNode {
  final TsReadRowResponseJs responseJs;

  TsReadRowResponseNode(this.responseJs);

  TsGetRow get row => TsGetRowNode(responseJs.row);
}

class TsGetRowResponseNode extends TsReadRowResponseNode
    implements TsGetRowResponse {
  TsGetRowResponseNode(TsReadRowResponseJs responseJs) : super(responseJs);

  @override
  String toString() => toDebugMap().toString();
}

class TsPutRowResponseNode extends TsReadRowResponseNode
    implements TsPutRowResponse {
  TsPutRowResponseNode(TsReadRowResponseJs responseJs) : super(responseJs);

  @override
  String toString() => toDebugMap().toString();
}

class TsDeleteRowResponseNode implements TsDeleteRowResponse {
  TsDeleteRowResponseNode();
}

class TsGetRangeResponseNode implements TsGetRangeResponse {
  final dynamic responseJs;
  TsGetRangeResponseNode(this.responseJs);

/*
  @override
  String toString() => toDebugMap().toString();

   */
}

// Response to native
TsGetRangeResponse getRangeResponseFromNative(dynamic nativeResponseJs) {
  if (nativeResponseJs != null) {
    return TsGetRangeResponseNode(nativeResponseJs);
  }
  return null;
}

dynamic tsSingleConditionToNative(TsColumnSingleCondition condition) {
  var columnConditionJs = util.callConstructor(
      tablestoreJs.SingleColumnCondition, [
    condition.name,
    condition.value,
    tsComparatorTypeToNative(condition.operator)
  ]);

  return columnConditionJs;
}

@JS()
@anonymous
abstract class CompositeConditionJs {
  external void addSubCondition(dynamic condition);
}

dynamic tsCompositeConditionToNative(TsColumnCompositeCondition condition) {
  var columnConditionJs =
      util.callConstructor(tablestoreJs.CompositeColumnCondition, [
    // tsComparatorTypeToNative(condition.)];
  ]);
  return columnConditionJs;
}

dynamic tsColumnConditionToNative(TsColumnCondition columnCondition) {
  if (columnCondition is TsColumnSingleCondition) {
    return tsSingleConditionToNative(columnCondition);
  } else if (columnCondition is TsColumnCompositeCondition) {
    return tsCompositeConditionToNative(columnCondition);
  } else {
    throw UnsupportedError('invalid condition $columnCondition');
  }
}

dynamic tsConditionToNative(TsCondition condition) {
  dynamic columnConditionJs;
  var columnCondition = condition.columnCondition;
  if (columnCondition != null) {
    columnConditionJs = tsColumnConditionToNative(columnCondition);
  }
  return util.callConstructor(tablestoreJs.Condition, [
    tsConditionRowExistenceExpectationToNative(
        condition.rowExistenceExpectation),
    columnConditionJs
  ]);
}

/// Value long (going though string to handle number at the limit
dynamic tsValueLongToNative(TsValueLong value) =>
    tablestoreJs.Long.fromString(value.toString());
