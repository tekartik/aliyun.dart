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

@JS()
@anonymous
class TsGetRowParamsJs {
  external factory TsGetRowParamsJs(
      {int maxVersions, String tableName, List<dynamic> primaryKey});
}

@JS()
@anonymous
class TsBatchGetRowParamsJs {
  external factory TsBatchGetRowParamsJs(
      {List<TsBatchGetRowParamsTableJs> tables});
}

@JS()
@anonymous
class TsBatchGetRowParamsTableJs {
  external factory TsBatchGetRowParamsTableJs(
      {int maxVersions, String tableName, dynamic primaryKey});
}

// {tables: [[{isOk: true, errorCode: null, errorMessage: null, tableName: test_key_string, capacityUnit: {read: 1, write: 0}, primaryKey: [{name: key, value: batch_1}], attributes: [{columnName: test, columnValue: {buffer: [1, 0, 0, 0, 0, 0, 0, 0], offset: 0}, timestamp: {buffer: [105, 65, 90, 108, 116, 1, 0, 0], offset: 0}}]}, {isOk: true, errorCode: null, errorMessage: null, tableName: test_key_string, capacityUnit: {read: 1, write: 0}, primaryKey: null, attributes: null}]], RequestId: 0005aec7-4095-ae6b-e5c1-720b0b23b32a}
@JS()
@anonymous
abstract class TsBatchGetRowResponseJs {
  List/*<List<TsBatchGetRowResponseRowJs>>*/ tables;
}

extension TsBatchGetRowResponseJsExt on TsBatchGetRowResponseJs {
  List<List<TsBatchGetRowResponseRowJs>> get extTables => tables
      .map((e) => (e as List)
          .map((e) => e as TsBatchGetRowResponseRowJs)
          .toList(growable: false))
      .toList(growable: false);
}

@JS()
@anonymous
abstract class TsBatchGetRowResponseRowJs {
  bool get isOk;

  int get errorCode;

  String get errorMessage;

  String get tableName;

  List get primaryKey;

  List get attributes;
}

Iterable<TsRowPrimaryKeyValueJs> batchRowPrimaryKeyValuesJs(
        TsBatchGetRowResponseRowJs js) =>
    js.primaryKey?.map((e) => e as TsRowPrimaryKeyValueJs);

Iterable<TsRowAttributeKeyValueJs> batchRowAttributeKeyValuesJs(
        TsBatchGetRowResponseRowJs js) =>
    js.attributes?.map((e) => e as TsRowAttributeKeyValueJs);

@JS()
@anonymous
abstract class TsBatchWriteRowResponseJs {
  List/*<TsBatchGetRowResponseRowJs>*/ tables;
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
  util.setProperty(kvJs, keyValue.name, tsJsify(keyValue.value));
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
external void jsObjectDefineProperty(Object obj, String name, dynamic property);

class JsArrayWrapper<T> {
  dynamic native = util.newObject();
  var _length = 0;

  int get length => _length;

  JsArrayWrapper() {
    _setLength(0);
  }

  void _setLength(int length) {
    _length = length;
    var property = util.newObject();
    util.setProperty(property, 'value', length);

    jsObjectDefineProperty(native, 'length', property);
  }

  void add(T value) {
    util.setProperty(native, length, value);
    _setLength(length + 1);
  }

  void addAll(Iterable<T> list) {
    list.forEach((element) {
      add(element);
    });
  }
}

dynamic toBatchGetRowParamsJs(TsBatchGetRowsRequest request) {
  var requestJs = util.newObject();

  var tablesJs = [];
  /*util.newObject();
  var tablesJsIndex = 0;*/
  request.tables.forEach((table) {
    var tableJs = util.newObject();
    util.setProperty(tableJs, 'tableName', table.tableName);
    var pksJs = JsArrayWrapper();
    table.primaryKeys.forEach((pk) {
      var pkcsJs = [];
      // var pkcsJsIndex = 0;
      pk.list.forEach((pkc) {
        var pkcJs = util.newObject();
        util.setProperty(pkcJs, 'key', 'batch_1');
        //util.setProperty(pkcsJs, pkcsJsIndex++, pkcJs);
        pkcsJs.add(pkcJs);
      });

      pksJs.add(pkcsJs);
    });
    util.setProperty(tableJs, 'primaryKey', pksJs.native);
    //util.callMethod(tablesJs, 'push', [tableJs]);
    tablesJs.add(tableJs);
    //util.setProperty(tablesJs, tablesJsIndex++, tableJs);
  });
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
  if (nativeResponseJs != null) {
    return TsPutRowResponseNode(nativeResponseJs as TsReadRowResponseJs);
  }
  return null;
}

TsUpdateRowResponse updateRowResponseFromNative(dynamic nativeResponseJs) {
  if (nativeResponseJs != null) {
    return TsUpdateRowResponseNode(nativeResponseJs as TsReadRowResponseJs);
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
class TsGetRangeResponseJs {
  external List get rows;
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
      fromNativePrimaryKey(rowPrimaryKeyValuesJs(rowJs));

  @override
  TsAttributes get attributes =>
      fromNativeAttributes(rowAttributeKeyValuesJs(rowJs));

  @override
  String toString() => toDebugMap().toString();
}

TsAttributes fromNativeAttributes(Iterable<TsRowAttributeKeyValueJs> native) {
  if (native == null) {
    return null;
  }
  return TsAttributes(native.map((kvJs) {
    return TsAttribute(kvJs.columnName, tsDartifyValue(kvJs.columnValue));
  }).toList());
}

TsPrimaryKey fromNativePrimaryKey(Iterable<TsRowPrimaryKeyValueJs> native) {
  if (native == null) {
    return null;
  }
  return TsPrimaryKey(native.map((kvJs) {
    return TsKeyValue(kvJs.name, tsDartifyValue(kvJs.value));
  }).toList());
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
  List<TsBatchGetRowsResponseRow> rows;
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
  List<List<TsBatchGetRowsResponseRow>> tables;

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
      primaryKey: fromNativePrimaryKey(batchRowPrimaryKeyValuesJs(rowJs)),
      attributes: fromNativeAttributes(batchRowAttributeKeyValuesJs(rowJs)));
}

/// It seems we cannot use Js here
class TsBatchGetRowsResponseRowImpl implements TsBatchGetRowsResponseRow {
  TsBatchGetRowsResponseRowImpl(
      {this.errorCode,
      this.errorMessage,
      this.tableName,
      this.isOk,
      this.attributes,
      this.primaryKey});

  @override
  String toString() => toDebugMap().toString();

  @override
  final TsAttributes attributes;

  @override
  final int errorCode;

  @override
  final String errorMessage;

  @override
  final bool isOk;

  @override
  final TsPrimaryKey primaryKey;

  @override
  final String tableName;
}

class TsGetRangeResponseNode implements TsGetRangeResponse {
  final TsGetRangeResponseJs responseJs;

  TsGetRangeResponseNode(this.responseJs);

  @override
  List<TsGetRow> get rows => responseJs.rows
      ?.map((e) => TsGetRowNode(e as TsReadRowJs))
      ?.toList(growable: false);
}

// Response to native
TsGetRangeResponse getRangeResponseFromNative(
    TsGetRangeResponseJs nativeResponseJs) {
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

dynamic tsDirectionToNative(TsDirection direction) {
  switch (direction) {
    case TsDirection.forward:
      return tablestoreNode.direction.FORWARD;
    case TsDirection.backward:
      return tablestoreNode.direction.BACKWARD;
  }
  throw UnsupportedError('invalid direction $direction');
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
  throw UnsupportedError('invalid write row type $type');
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

/// Value infinite
dynamic tsValueInfiniteToNative(TsValueInfinite value) {
  if (value == TsValueInfinite.min) {
    return tablestoreJs.INF_MIN;
  }
  if (value == TsValueInfinite.max) {
    return tablestoreJs.INF_MAX;
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
              if (table.tableName != null) 'tableName': table.tableName,
              'rows': TsArrayHack(table.rows.map((row) => <String, dynamic>{
                    // Needed
                    'type': row.type,

                    // Needed
                    'condition': row.condition ?? TsCondition.ignore,

                    if (row.primaryKey != null)
                      // !singular
                      'primaryKey': tsPrimaryKeyParams(row.primaryKey),

                    if (row.data != null)
                      'attributeColumns': tsAttributeColumnsParams(row.data),
                    'returnContent': {
                      'returnType': tsNodeCommon.returnType.Primarykey
                    }
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
              if (table.tableName != null) 'tableName': table.tableName,
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
