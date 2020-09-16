@JS()
library tekartik_aliyun_tablestore_node.ts_interop;

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_exception.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_table_interop.dart'
    show PrimaryKeyTypeJs, TsClientListTableParamsJs, TsClientTableParamsJs;

// ignore_for_file: non_constant_identifier_names

import 'import_interop.dart';

bool debugTs = true; // devWarning(true); true for now until it works

/// A structure for options provided to Firebase.
@JS()
@anonymous
class TsClientOptionsJs {
  external String get accessKeyId;

  external set accessKeyId(String s);

  external String get secretAccessKey;

  external set endpoint(String s);

  external String get endpoint;

  external set instancename(String s);

  external String get instancename;

  external factory TsClientOptionsJs(
      {String accessKeyId,
      String secretAccessKey,
      String endpoint,
      String instancename});
}

@JS()
@anonymous
abstract class TablestoreJs {
  /// Reference to constructor Client.
  external dynamic get Client;

  /// Key type definition
  external PrimaryKeyTypeJs get PrimaryKeyType;

  external TsRowExistenceExpectationJs get RowExistenceExpectation;

  external TsReturnTypeJs get ReturnType;

  external TsConstantComparatorTypeJs get ComparatorType;

  external TsConstantLogicalOperatorJs get LogicalOperator;

  external TsConstantDirectionJs get Direction;

  external TsNodeLongClassJs get Long;

  /// key value min
  external dynamic get INF_MIN;

  /// key value min
  external dynamic get INF_MAX;

  /// Constructors
  external dynamic get Condition;

  /// Constructors
  external dynamic get SingleColumnCondition;

  /// Constructors
  external dynamic get CompositeCondition;
}

/// Wrap a native error
TsExceptionNode wrapNativeError(dynamic err) {
  if (err is TsExceptionNode) {
    return err;
  }
  Map errMap;
  String message;
  // Try json
  try {
    errMap = jsObjectAsMap(err);
  } catch (_) {
    message = err.toString();
  }

  if (debugTs) {
    if (errMap != null) {
      print('TS!: errMap: ${jsonEncode(errMap)}');
    } else {
      print('TS!: err: ${nativeDataToDebugString(err)}');
    }
  }
  return TsExceptionNode(message: message, map: errMap);
}

@JS()
@anonymous
class TsClientJs {
  external void listTable(TsClientListTableParamsJs params, Function callback);

  external void deleteTable(TsClientTableParamsJs params, Function callback);

  external void describeTable(TsClientTableParamsJs params, Function callback);

  external void batchWriteRow(dynamic params, Function callback);

  external void batchGetRow(dynamic params, Function callback);

  external void putRow(dynamic params, Function callback);

  external void updateRow(dynamic params, Function callback);

  external void deleteRow(dynamic params, Function callback);

  external void getRow(dynamic params, Function callback);

  external void getRange(dynamic params, Function callback);

  external void createTable(dynamic params, Function callack);

  external void startLocalTransaction(dynamic params, Function callback);
}

final tablestoreJs = require('tablestore') as TablestoreJs;

/// Convert a native object to a debug string
String nativeDataToDebugString(dynamic data) {
  String text;
  try {
    text = jsonEncode(jsObjectAsMap(data));
  } catch (_) {
    try {
      text = jsObjectToDebugString(data);
    } catch (_) {
      text = data.toString();
    }
  }
  return text;
}
