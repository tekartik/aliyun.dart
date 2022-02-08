@JS()
library tekartik_aliyun_tablestore_node.ts_row_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/import.dart';
import 'package:tekartik_aliyun_tablestore_node/src/import_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/interop/utils_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_common.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/universal/ts_node_universal.dart';

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
abstract class TsConstantDirectionJs implements TsConstantDirection {
  @override
  external String get FORWARD;

  @override
  external String get BACKWARD;
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
    return tablestoreJs!.Long.fromNumber(value);
  }

  @override
  TsNodeLong fromString(String value) {
    return tablestoreJs!.Long.fromString(value);
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

@JS()
@anonymous
class TsGetRowParamsJs {
  external factory TsGetRowParamsJs(
      {int? maxVersions, String? tableName, List<dynamic>? primaryKey});
}

@JS()
@anonymous
class TsBatchGetRowParamsJs {
  external factory TsBatchGetRowParamsJs(
      {List<TsBatchGetRowParamsTableJs>? tables});
}

@JS()
@anonymous
class TsBatchGetRowParamsTableJs {
  external factory TsBatchGetRowParamsTableJs(
      {int? maxVersions, String? tableName, dynamic primaryKey});
}

// {tables: [[{isOk: true, errorCode: null, errorMessage: null, tableName: test_key_string, capacityUnit: {read: 1, write: 0}, primaryKey: [{name: key, value: batch_1}], attributes: [{columnName: test, columnValue: {buffer: [1, 0, 0, 0, 0, 0, 0, 0], offset: 0}, timestamp: {buffer: [105, 65, 90, 108, 116, 1, 0, 0], offset: 0}}]}, {isOk: true, errorCode: null, errorMessage: null, tableName: test_key_string, capacityUnit: {read: 1, write: 0}, primaryKey: null, attributes: null}]], RequestId: 0005aec7-4095-ae6b-e5c1-720b0b23b32a}
@JS()
@anonymous
abstract class TsBatchGetRowResponseJs {
  external List/*<List<TsBatchGetRowResponseRowJs>>*/ tables;
}

extension TsBatchGetRowResponseJsExt on TsBatchGetRowResponseJs {
  List<List<TsBatchGetRowResponseRowJs>> get extTables => tables
      .map((e) => (e as List)
          .map((e) => e as TsBatchGetRowResponseRowJs)
          .toList(growable: false))
      .toList(growable: false);
}

// {"isOk":false,"errorCode":"OTSConditionCheckFail","errorMessage":"Condition check failed.","tableName":"test_key_string","capacityUnit":"","primaryKey":null,"attributes":null}
@JS()
@anonymous
abstract class TsBatchGetRowResponseRowJs {
  bool get isOk;

  String get errorCode;

  String get errorMessage;

  String get tableName;

  List? get primaryKey;

  List? get attributes;
}

Iterable<TsRowPrimaryKeyValueJs>? batchRowPrimaryKeyValuesJs(
        TsBatchGetRowResponseRowJs js) =>
    js.primaryKey?.map((e) => e as TsRowPrimaryKeyValueJs);

Iterable<TsRowAttributeKeyValueJs>? batchRowAttributeKeyValuesJs(
        TsBatchGetRowResponseRowJs js) =>
    js.attributes?.map((e) => e as TsRowAttributeKeyValueJs);

@JS()
@anonymous
abstract class TsBatchWriteRowResponseJs {
  external List/*<TsBatchGetRowResponseRowJs>*/ tables;
}

extension TsBatchWriteRowResponseJsExt on TsBatchWriteRowResponseJs {
  List<TsBatchGetRowResponseRowJs> get rows => tables
      .map((e) => e as TsBatchGetRowResponseRowJs)
      .toList(growable: false);
}

// Empty we set propery on it
@JS()
@anonymous
class TsKeyValueJs {
  external factory TsKeyValueJs();
}

TsKeyValueJs tsKeyValueToNative(TsKeyValue keyValue) {
  var kvJs = TsKeyValueJs();
  util.setProperty(kvJs, keyValue.name, tsValueToNative(keyValue.value));
  return kvJs;
}

/*
dynamic /*TsKeyValueJs*/ tsKeyValueToNative(TsKeyValue keyValue) {
  var object = JsObject(context['Object'] as JsFunction);
  var object = JsObject.jsify({});
  util.setProperty(object, keyValue.name, tsJsify(keyValue.value));
  return object;
}*/
/*
  var kvJs = TsKeyValueJs();
  util.setProperty(kvJs, keyValue.name, );
  return kvJs;
}*/

List<dynamic> tsPrimaryKeyToNative(TsPrimaryKey primaryKey) =>
    primaryKey.list.map(tsKeyValueToNative).toList();

TsGetRowParamsJs toGetRowParamsJs(TsGetRowRequest request) {
  return TsGetRowParamsJs(
      maxVersions: 1,
      tableName: request.tableName,
      primaryKey: tsPrimaryKeyToNative(request.primaryKey));
}

@JS('Object.keys')
external void jsObjectDefineProperty(
    Object? obj, String name, dynamic property);

class JsArrayWrapper<T> {
  var native = util.newObject() as Object;
  var _length = 0;

  int get length => _length;

  JsArrayWrapper() {
    _setLength(0);
  }

  void _setLength(int length) {
    _length = length;
    var property = util.newObject() as Object;
    util.setProperty(property, 'value', length);

    jsObjectDefineProperty(native, 'length', property);
  }

  void add(T value) {
    util.setProperty(native, length, value);
    _setLength(length + 1);
  }

  void addAll(Iterable<T> list) {
    for (var element in list) {
      add(element);
    }
  }
}

dynamic toBatchGetRowParamsJs(TsBatchGetRowsRequest request) {
  var requestJs = util.newObject() as Object;

  var tablesJs = [];
  /*util.newObject();
  var tablesJsIndex = 0;*/
  for (var table in request.tables) {
    var tableJs = util.newObject() as Object;
    util.setProperty(tableJs, 'tableName', table.tableName);
    var pksJs = JsArrayWrapper();
    for (var pk in table.primaryKeys) {
      var pkcsJs = [];
      // var pkcsJsIndex = 0;
      for (var pkc in pk.list) {
        var pkcJs = util.newObject() as Object;
        util.setProperty(pkcJs, pkc.name, pkc.value);
        //util.setProperty(pkcsJs, pkcsJsIndex++, pkcJs);
        pkcsJs.add(pkcJs);
      }

      pksJs.add(pkcsJs);
    }
    util.setProperty(tableJs, 'primaryKey', pksJs.native);
    //util.callMethod(tablesJs, 'push', [tableJs]);
    tablesJs.add(tableJs);
    //util.setProperty(tablesJs, tablesJsIndex++, tableJs);
  }
  util.setProperty(requestJs, 'tables', tablesJs);

  /*
  var array = JsArray.from([
    {'test': 1}
  ]);
  print('#1 ${jsObjectKeys(array)}');
  print('#2 ${jsObjectKeys(util.newObject())}');
  var arrayW = JsArrayWrapper();
  arrayW.add({'test': 123});
  arrayW.add({'test': 456});
  print('#3 ${jsObjectKeys(arrayW.native)}');

   */
  return requestJs;
}

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
  return TsPutRowResponseNode(nativeResponseJs as TsReadRowResponseJs);
}

TsUpdateRowResponse updateRowResponseFromNative(dynamic nativeResponseJs) {
  return TsUpdateRowResponseNode(nativeResponseJs as TsReadRowResponseJs);
}

TsStartLocalTransactionResponse startLocalTransactionRowResponseFromNative(
    dynamic nativeResponseJs) {
  return TsStartLocalTransactionResponseNode(
      nativeResponseJs as TsStartLocalTransactionResponseJs);
}

// Response to native
TsDeleteRowResponse deleteRowResponseFromNative(dynamic nativeResponseJs) {
  return TsDeleteRowResponseNode();
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
class TsStartLocalTransactionResponseJs {
  external dynamic get transactionId;
}

@JS()
@anonymous
class TsGetRangeResponseJs {
  external List get rows;

  external List get nextStartPrimaryKey;
}

Iterable<TsRowPrimaryKeyValueJs> getRangeResponseNextStartPrimaryKeyValuesJs(
        TsGetRangeResponseJs js) =>
    js.nextStartPrimaryKey.map((e) => e as TsRowPrimaryKeyValueJs);

@JS()
@anonymous
class TsReadRowJs {
  external List? get primaryKey;

  external List? get attributes;
}

Iterable<TsRowPrimaryKeyValueJs>? rowPrimaryKeyValuesJs(TsReadRowJs js) =>
    js.primaryKey?.map((e) => e as TsRowPrimaryKeyValueJs);

Iterable<TsRowAttributeKeyValueJs>? rowAttributeKeyValuesJs(TsReadRowJs js) =>
    js.attributes?.map((e) => e as TsRowAttributeKeyValueJs);

// Response to native
TsGetRowResponse getRowResponseFromNative(dynamic nativeResponseJs) {
  return TsGetRowResponseNode(nativeResponseJs as TsReadRowResponseJs);
}

class TsGetRowNode implements TsGetRow {
  final TsReadRowJs rowJs;

  TsGetRowNode(this.rowJs);

  @override
  TsPrimaryKey? get primaryKey =>
      fromNativePrimaryKeyOrNull(rowPrimaryKeyValuesJs(rowJs));

  @override
  TsAttributes? get attributes =>
      fromNativeAttributesOrNull(rowAttributeKeyValuesJs(rowJs));

  @override
  String toString() => toDebugMap().toString();

  @override
  bool get exists => primaryKey != null;
}

TsAttributes fromNativeAttributes(Iterable<TsRowAttributeKeyValueJs> native) {
  return TsAttributes(native.map((kvJs) {
    return TsAttribute(
        kvJs.columnName, tsDartifyValue(kvJs.columnValue) as Object);
  }).toList());
}

TsAttributes? fromNativeAttributesOrNull(
    Iterable<TsRowAttributeKeyValueJs>? native) {
  if (native == null) {
    return null;
  }
  return fromNativeAttributes(native);
}

TsPrimaryKey fromNativePrimaryKey(Iterable<TsRowPrimaryKeyValueJs> native) {
  return TsPrimaryKey(native.map((kvJs) {
    return TsKeyValue(kvJs.name, tsDartifyValue(kvJs.value) as Object);
  }).toList());
}

TsPrimaryKey? fromNativePrimaryKeyOrNull(
    Iterable<TsRowPrimaryKeyValueJs>? native) {
  if (native == null) {
    return null;
  }
  return fromNativePrimaryKey(native);
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

class TsUpdateRowResponseNode extends TsReadRowResponseNode
    implements TsUpdateRowResponse {
  TsUpdateRowResponseNode(TsReadRowResponseJs responseJs) : super(responseJs);

  @override
  String toString() => toDebugMap().toString();
}

class TsStartLocalTransactionResponseNode
    implements TsStartLocalTransactionResponse {
  final TsStartLocalTransactionResponseJs responseJs;

  TsStartLocalTransactionResponseNode(this.responseJs);

  @override
  String toString() => toDebugMap().toString();

  @override
  dynamic get transactionId => responseJs.transactionId;
}

class TsDeleteRowResponseNode implements TsDeleteRowResponse {
  TsDeleteRowResponseNode();
}

class TsBatchWriteRowsResponseNode implements TsBatchWriteRowsResponse {
  final TsBatchWriteRowResponseJs responseJs;

  TsBatchWriteRowsResponseNode(this.responseJs) {
    rows = responseJs.rows
        .map((e) => fromBatchGetRowResponseRowNative(e))
        .toList(growable: false);
  }

  @override
  late List<TsBatchGetRowsResponseRow> rows;
}

class TsBatchGetRowsResponseNode implements TsBatchGetRowsResponse {
  final TsBatchGetRowResponseJs responseJs;

  TsBatchGetRowsResponseNode(this.responseJs) {
    tables = responseJs.extTables
        .map((rows) => rows
            .map((e) => fromBatchGetRowResponseRowNative(e))
            .toList(growable: false))
        .toList(growable: false);
  }

  @override
  late List<List<TsBatchGetRowsResponseRow>> tables;

  @override
  String toString() => toDebugMap().toString();
}

/*
class TsBatchGetRowsResponseRowNode implements TsBatchGetRowsResponseRow {
  final TsBatchGetRowResponseRowJs rowJs;

  TsBatchGetRowsResponseRowNode(this.rowJs);

  @override
  // TODO: implement attributes
  TsAttributes get attributes => throw UnimplementedError();

  @override
  int get errorCode => rowJs.errorCode;

  @override
  String get errorMessage => rowJs.errorMessage;

  @override
  bool get isOk => rowJs.isOk;

  @override
  // TODO: implement primaryKey
  TsPrimaryKey get primaryKey => throw UnimplementedError();

  @override
  String get tableName => rowJs.tableName;

  @override
  String toString() => toDebugMap().toString();
}
*/
TsBatchGetRowsResponseRow fromBatchGetRowResponseRowNative(
    TsBatchGetRowResponseRowJs rowJs) {
  return TsBatchGetRowsResponseRowImpl(
      isOk: rowJs.isOk,
      errorCode: rowJs.errorCode,
      errorMessage: rowJs.errorMessage,
      tableName: rowJs.tableName,
      primaryKey: fromNativePrimaryKeyOrNull(batchRowPrimaryKeyValuesJs(rowJs)),
      attributes:
          fromNativeAttributesOrNull(batchRowAttributeKeyValuesJs(rowJs)));
}

/// It seems we cannot use Js here
class TsBatchGetRowsResponseRowImpl implements TsBatchGetRowsResponseRow {
  TsBatchGetRowsResponseRowImpl(
      {required this.errorCode,
      required this.errorMessage,
      required this.tableName,
      required this.isOk,
      required this.attributes,
      required this.primaryKey});

  @override
  String toString() => toDebugMap().toString();

  @override
  final TsAttributes? attributes;

  @override
  final String? errorCode;

  @override
  final String? errorMessage;

  @override
  final bool isOk;

  @override
  final TsPrimaryKey? primaryKey;

  @override
  final String tableName;
}

class TsGetRangeResponseNode implements TsGetRangeResponse {
  final TsGetRangeResponseJs responseJs;

  TsGetRangeResponseNode(this.responseJs);

  @override
  List<TsGetRow> get rows => responseJs.rows
      .map((e) => TsGetRowNode(e as TsReadRowJs))
      .toList(growable: false);

  @override
  TsPrimaryKey get nextStartPrimaryKey => fromNativePrimaryKey(
      getRangeResponseNextStartPrimaryKeyValuesJs(responseJs));
}

// Response to native
TsGetRangeResponse getRangeResponseFromNative(
    TsGetRangeResponseJs nativeResponseJs) {
  return TsGetRangeResponseNode(nativeResponseJs);
}

dynamic tsSingleConditionToNative(TsColumnSingleCondition condition) {
  var columnConditionJs =
      util.callConstructor(tablestoreJs!.SingleColumnCondition, [
    condition.name,
    tsValueToNative(condition.value),
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
  var columnConditionJs = util.callConstructor(tablestoreJs!.CompositeCondition,
          [tsLogicalOperatorTypeToNative(condition.operator)])
      as CompositeConditionJs?;
  for (var sub in condition.list) {
    columnConditionJs!.addSubCondition(tsColumnConditionToNative(sub));
  }

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

dynamic tsDirectionToNative(TsDirection direction) {
  switch (direction) {
    case TsDirection.forward:
      return tablestoreNode.direction.FORWARD;
    case TsDirection.backward:
      return tablestoreNode.direction.BACKWARD;
  }
  // throw UnsupportedError('invalid direction $direction');
}

dynamic tsWriteRowTypeToNative(TsWriteRowType type) {
  switch (type) {
    case TsWriteRowType.put:
      return 'PUT';
    case TsWriteRowType.update:
      return 'UPDATE';
    case TsWriteRowType.delete:
      return 'DELETE';
  }
  //throw UnsupportedError('invalid write row type $type');
}

dynamic tsConditionToNative(TsCondition condition) {
  dynamic columnConditionJs;
  var columnCondition = condition.columnCondition;
  if (columnCondition != null) {
    columnConditionJs = tsColumnConditionToNative(columnCondition);
  }
  return util.callConstructor(tablestoreJs!.Condition, [
    tsConditionRowExistenceExpectationToNative(
        condition.rowExistenceExpectation),
    columnConditionJs
  ]);
}

/// Value long (going though string to handle number at the limit
dynamic tsValueLongToNative(TsValueLong value) =>
    tablestoreJs!.Long.fromString(value.toString());

/// Value infinite
dynamic tsValueInfiniteToNative(TsValueInfinite value) {
  if (value == TsValueInfinite.min) {
    return tablestoreJs!.INF_MIN;
  }
  if (value == TsValueInfinite.max) {
    return tablestoreJs!.INF_MAX;
  }
  throw 'Unsupported TsValueInfinite($value)';
}

//
// {"tables":[
//  {"tableName":"test_key_string","rows":[{"condition":{"rowExistenceExpectation":0,"columnCondition":null},"type":"PUT","primaryKey":[{"key":"batch_1"}],"attributeColumns":[{"test":{"buffer":[1,0,0,0,0,0,0,0],"offset":0}}]},{"condition":{"rowExistenceExpectation":0,"columnCondition":null},"type":"PUT","primaryKey":[{"key":"batch_2"}],"attributeColumns":[{"test":{"buffer":[2,0,0,0,0,0,0,0],"offset":0}}]}]}]}
Map<String, dynamic> toWriteRowsParams(TsBatchWriteRowsRequest request) {
  var map = <String, dynamic>{
    'tables': request.tables
        .map((table) => <String, dynamic>{
              'tableName': table.tableName,
              'rows': TsArrayHack(table.rows.map((row) {
                return <String, dynamic>{
                  // Needed
                  'type': row.type,

                  // Needed
                  'condition': row.condition ?? TsCondition.ignore,

                  'primaryKey': tsPrimaryKeyParams(row.primaryKey),

                  if (row is TsBatchWriteRowsRequestPutRow &&
                      (row.data != null))
                    'attributeColumns': tsAttributeColumnsParams(row.data!)
                  else if (row is TsBatchWriteRowsRequestUpdateRow)
                    'attributeColumns': tsUpdateAttributesParams(row.data),
                  'returnContent': {
                    'returnType': tsNodeCommon.returnType.Primarykey
                  }
                };
              }))
            })
        .toList(growable: false)
  };

  return map;
}

Map<String, dynamic> toBatchGetRowsParams(TsBatchGetRowsRequest request) {
  var map = <String, dynamic>{
    'tables': request.tables
        .map((table) => <String, dynamic>{
              'tableName': table.tableName,
              // exp: TODO not hardcode
              'maxVersions': 1,
              // !singular
              'primaryKey':
                  TsArrayHack(table.primaryKeys.map(tsPrimaryKeyParams)),
              if (table.columns != null) 'columnsToGet': table.columns,
            })
        .toList()
  };

  return map;
}
