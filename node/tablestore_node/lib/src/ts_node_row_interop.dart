@JS()
library tekartik_aliyun_tablestore_node.ts_row_interop;

import 'package:js/js.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/interop/utils.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_interop.dart';

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
  external TsLongJs fromText(String value);
}

class TsNodeLongClassImpl implements TsNodeLongClass {
  @override
  TsNodeLong fromNumber(int value) {
    return tablestoreJs.Long.fromNumber(value);
  }

  @override
  TsNodeLong fromText(String value) {
    return tablestoreJs.Long.fromText(value);
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
    return TsPutRowResponseNode(nativeResponseJs);
  }
  return null;
}

// Response to native
TsDeleteRowResponse deleteRowResponseFromNative(dynamic nativeResponseJs) {
  if (nativeResponseJs != null) {
    return TsDeleteRowResponseNode(nativeResponseJs);
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
    return TsGetRowResponseNode(nativeResponseJs);
  }
  return null;
}

class TsGetRowNode implements TsGetRow {
  final TsReadRowJs rowJs;

  TsGetRowNode(this.rowJs);

  @override
  TsPrimaryKey get primaryKey =>
      TsPrimaryKey(rowPrimaryKeyValuesJs(rowJs).map((kvJs) {
        return TsKeyValue(kvJs.name, tsDartify(kvJs.value));
      }).toList());

  @override
  List<TsAttribute> get attributes =>
      rowAttributeKeyValuesJs(rowJs).map((kvJs) {
        return TsAttribute(kvJs.columnName, tsDartify(kvJs.columnValue));
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
  TsDeleteRowResponseNode(TsReadRowResponseJs responseJs);

/*
  @override
  String toString() => toDebugMap().toString();

   */
}
