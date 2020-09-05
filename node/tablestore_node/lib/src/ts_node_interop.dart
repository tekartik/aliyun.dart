@JS()
library tekartik_aliyun_tablestore_node.ts_interop;

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_table_interop.dart'
    show PrimaryKeyTypeJs, TsClientListTableParamsJs, TsClientTableParamsJs;

import 'package:tekartik_common_utils/int_utils.dart';
import 'package:tekartik_http/http.dart';

import 'import.dart';

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

  external TsNodeLongClassJs get Long;

  /// Constructory
  external dynamic get Condition;
}

// JS:
// {"message":"\n\u0011OTSObjectNotExist\u0012\u001fRequested table does not exist.","code":404,"headers":{"date":"Fri, 04 Sep 2020 08:20:18 GMT","transfer-encoding":"chunked","connection":"keep-alive","authorization":"OTS LTAI4GCzUBNEhUsjDMwxrpHs:mE9Ca6pH7IeIqUxFyOblMZVj9Lg=","x-ots-contentmd5":"e2enEqtXyX/3YTqhbiPDtw==","x-ots-contenttype":"protocol buffer","x-ots-date":"2020-09-04T08:20:18.991322Z","x-ots-requestid":"0005ae78-8a0d-52c0-e6c1-720b05604f7b"},"time":{},"retryable":false}
class TablestoreNodeException implements Exception {
  final String _message;
  final Map /*?*/ map;

  String get message =>
      _message ?? _errMapValue('message')?.toString() ?? 'error';

  dynamic _errMapValue(String key) => map != null ? map[key] : null;

  // Message can be null
  TablestoreNodeException({String /*?*/ message, this.map /*?*/
      })
      : _message = message;

  // TableStoreNodeException(404:OTSObjec
  int get code => parseInt(_errMapValue('code'));

  bool get retryable => parseBool(_errMapValue('retryable'));

  bool get isNotFound => code == httpStatusCodeNotFound;

  @override
  String toString() => 'TableStoreNodeException($message, $map)';
}

/// Wrap a native error
TablestoreNodeException wrapNativeError(dynamic err) {
  if (err is TablestoreNodeException) {
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
  return TablestoreNodeException(message: message, map: errMap);
}

@JS()
@anonymous
class TsClientJs {
  external void listTable(TsClientListTableParamsJs params, Function callback);

  external void deleteTable(TsClientTableParamsJs params, Function callback);

  external void describeTable(TsClientTableParamsJs params, Function callback);

  external void putRow(dynamic params, Function callback);

  external void getRow(TsGetRowParamsJs params, Function callback);

  external void createTable(dynamic params, Function callack);
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
