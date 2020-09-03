@JS()
library tekartik_aliyun_tablestore_node.ts_interop;

import 'dart:js_util';

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';
import 'package:node_interop/util.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_common_utils/int_utils.dart';
import 'package:tekartik_http/http.dart';

import 'import.dart';

/// A structure for options provided to Firebase.
@JS()
@anonymous
class _TsClientOptionsJs {
  external String get accessKeyId;

  external set accessKeyId(String s);

  external String get secretAccessKey;

  external set endpoint(String s);

  external String get endpoint;

  external set instancename(String s);

  external String get instancename;

  external factory _TsClientOptionsJs(
      {String accessKeyId,
      String secretAccessKey,
      String endpoint,
      String instancename,
      String storageBucket,
      String messagingSenderId});
}

@JS()
@anonymous
abstract class _TablestoreJs {
  /// Reference to constructor Client.
  external dynamic get Client;

  external PrimaryKeyTypeJs get PrimaryKeyType;
}

@JS()
@anonymous
// // Key types: {INTEGER: 1, STRING: 2, BINARY: 3}
abstract class PrimaryKeyTypeJs {
  external int get INTEGER;
  external int get STRING;
  external int get BINARY;
}

@JS()
@anonymous
class _TsClientListTableParamsJs {}

@JS()
@anonymous
class _TsClientTableParamsJs {
  external factory _TsClientTableParamsJs({String tableName});
}

/*
var params = {
  tableMeta: {
    tableName: 'sampleTable',
    primaryKey: [
      {
        name: 'gid',
        type: 'INTEGER'
      },
      {
        name: 'uid',
        type: 'INTEGER'
      }
    ]
  },
  reservedThroughput: {
    capacityUnit: {
      read: 0,
      write: 0
    }
  },
  tableOptions: {
    timeToLive: -1,// 数据的过期时间, 单位秒, -1代表永不过期. 假如设置过期时间为一年, 即为 365 * 24 * 3600.
    maxVersions: 1// 保存的最大版本数, 设置为1即代表每列上最多保存一个版本(保存最新的版本).
  },
  streamSpecification: {
    enableStream: true, //开启Stream
    expirationTime: 24 //Stream的过期时间，单位是小时，最长为168，设置完以后不能修改
  }
};

@JS()
@anonymous
class _TsClientCreateTableParamsJs {
  external String get tableName;
  external set tableName(String tableName);
  external factory _TsClientDeleteTableParamsJs({String tableName});
}
*/
class TablestoreNodeException implements Exception {
  final String message;

  TablestoreNodeException(this.message);

  // TableStoreNodeException(404:OTSObjec
  int get httpStatusCode => parseStartInt(message);

  bool get isNotFound => httpStatusCode == httpStatusCodeNotFound;

  @override
  String toString() => 'TableStoreNodeException($message)';
}

@JS()
@anonymous
class _TsClientJs {
  external void listTable(_TsClientListTableParamsJs params, Function callback);

  external void deleteTable(_TsClientTableParamsJs params, Function callback);

  external void describeTable(_TsClientTableParamsJs params, Function callback);

  external void createTable(dynamic params, Function callack);
}

@JS()
@anonymous
class _TsTableJs {}

class TsTableNode implements TsTable {
  final _TsTableJs native;

  TsTableNode(this.native);
}

@JS()
@anonymous
abstract class _TsClientListTableResponseJs {
  List<String> get tableNames;
}

//     "primaryKey": [
//       {
//         "name": "gid",
//         "type": 1
//       },
@JS()
@anonymous
abstract class _TsClientPrimaryKey {
  external String get name;

  external int get type;
}

//   "tableMeta": {
//     "primaryKey": [
//       {
//         "name": "gid",
//         "type": 1
//       },
//       {
//         "name": "uid",
//         "type": 1
//       }
//     ],
//     "definedColumn": [],
//     "indexMeta": [],
//     "tableName": "test_create1"
//   },
@JS()
@anonymous
abstract class _TsClientTableDescriptionTableMeta {
  external String get tableName;

  external List<dynamic /*_TsClientPrimaryKey*/ > get primaryKey;
}

List<_TsClientPrimaryKey> tableMetaPrimaryKeys(
        _TsClientTableDescriptionTableMeta tableMeta) =>
    tableMeta.primaryKey.cast<_TsClientPrimaryKey>().toList(growable: false);

// {
//   "shardSplits": [],
//   "indexMetas": [],
//   "tableMeta": {
//     "primaryKey": [
//       {
//         "name": "gid",
//         "type": 1
//       },
//       {
//         "name": "uid",
//         "type": 1
//       }
//     ],
//     "definedColumn": [],
//     "indexMeta": [],
//     "tableName": "test_create1"
//   },
//   "reservedThroughputDetails": {
//     "capacityUnit": {
//       "read": 0,
//       "write": 0
//     },
//     "lastIncreaseTime": {
//       "low": 1599074982,
//       "high": 0,
//       "unsigned": false
//     }
//   },
//   "tableOptions": {
//     "timeToLive": -1,
//     "maxVersions": 1,
//     "deviationCellVersionInSec": {
//       "low": 86400,
//       "high": 0,
//       "unsigned": false
//     }
//   },
//   "tableStatus": 1,
//   "streamDetails": {
//     "enableStream": true,
//     "streamId": "test_create1_1599074982214249",
//     "expirationTime": 24,
//     "lastEnableTime": {
//       "low": -1471628695,
//       "high": 372313,
//       "unsigned": false
//     }
//   },
//   "RequestId": "0005ae6f-af63-250c-a4c1-720b08797701"
// }
@JS()
@anonymous
abstract class _TsClientTableDescription {
  external _TsClientTableDescriptionTableMeta get tableMeta;
}

class TsClientNode with TsClientMixin implements TsClient {
  final _TsClientJs native;

  TsClientNode(this.native);

  void _handleError(Completer completer, dynamic err) {
    if (!completer.isCompleted) {
      if (err is TablestoreNodeException) {
        completer.completeError(err);
      } else {
        //  TableStoreNodeException(404:
        //   OTSObjectNotExistRequested table does not exist.)
        completer.completeError(TablestoreNodeException(err.toString()));
      }
    }
  }

  void _handleSuccess<T>(Completer<T> completer, T data) {
    if (!completer.isCompleted) {
      completer.complete(data);
    }
  }

  @override
  Future<List<String>> listTableNames() {
    var completer = Completer<List<String>>();
    try {
      native.listTable(_TsClientListTableParamsJs(), allowInterop((err, data) {
        if (err != null) {
          _handleError(completer, err);
        } else {
          var response = data as _TsClientListTableResponseJs;

          // devPrint(jsonPretty(jsObjectAsMap(response)));
          // {tableNames: [Exp1, Exp2], RequestId: 0005ae3d-8b60-c9d8-a4c1-720b0589c481}

          _handleSuccess(completer, List<String>.from(response.tableNames));
        }
      }));
    } catch (e) {
      _handleError(completer, e);
    }
    return completer.future;
  }

  @override
  Future createTable(String name) async {
    var params = {
      'tableMeta': {
        'tableName': name,
        'primaryKey': [
          {'name': 'gid', 'type': 'INTEGER'},
          {'name': 'uid', 'type': 'INTEGER'}
        ]
      },
      'reservedThroughput': {
        'capacityUnit': {'read': 0, 'write': 0}
      },
      'tableOptions': {
        'timeToLive':
            -1, // 数据的过期时间, 单位秒, -1代表永不过期. 假如设置过期时间为一年, 即为 365 * 24 * 3600.
        'maxVersions': 1 // 保存的最大版本数, 设置为1即代表每列上最多保存一个版本(保存最新的版本).
      },
      'streamSpecification': {
        'enableStream': true, //开启Stream
        'expirationTime': 24 //Stream的过期时间，单位是小时，最长为168，设置完以后不能修改
      }
    };
    var completer = Completer<List<String>>();
    try {
      native.createTable(jsify(params), allowInterop((err, data) {
        if (err != null) {
          _handleError(completer, err);
        } else {
          var response = data;
          print(jsObjectToDebugString(response));
          // {tableNames: [Exp1, Exp2], RequestId: 0005ae3d-8b60-c9d8-a4c1-720b0589c481}

          _handleSuccess(completer, null);
        }
      }));
    } catch (e) {
      _handleError(completer, e);
    }
    return completer.future;
  }

  @override
  String toString() {
    return 'TsClientNode()';
  }

  @override
  Future deleteTable(String name) {
    var completer = Completer<void>();
    try {
      native.deleteTable(_TsClientTableParamsJs(tableName: name),
          allowInterop((err, data) {
        if (err != null) {
          // TableStoreNodeException(404:OTSObjectNotExistRequested table does not exist.)
          _handleError(completer, err);
        } else {
          var response = data;
          print(jsObjectToDebugString(response));
          // {tableNames: [Exp1, Exp2], RequestId: 0005ae3d-8b60-c9d8-a4c1-720b0589c481}

          _handleSuccess(completer, null);
        }
      }));
    } catch (e) {
      _handleError(completer, e);
    }
    return completer.future;
  }

  Future<dynamic> _nativeOperationWithCallback<T>(
      dynamic Function(Function callback) action) {
    var completer = Completer<void>();
    try {
      action(allowInterop((err, data) {
        if (err != null) {
          // TableStoreNodeException(404:OTSObjectNotExistRequested table does not exist.)
          _handleError(completer, err);
        } else {
          // var response = data;
          // devPrint(jsObjectToDebugString(response));

          // Pretty print debug
          // devPrint(jsonPretty(jsObjectAsMap(response)));
          // {tableNames: [Exp1, Exp2], RequestId: 0005ae3d-8b60-c9d8-a4c1-720b0589c481}

          _handleSuccess(completer, data);
        }
      }));
    } catch (e) {
      _handleError(completer, e);
    }
    return completer.future;
  }

  @override
  Future<TsTableDescription> describeTable(String tableName) async {
    var nativeDesc = await _nativeOperationWithCallback((callback) {
      native.describeTable(
          _TsClientTableParamsJs(tableName: tableName), callback);
    });
    return tableDescriptionFromNative(nativeDesc);
  }
}

TsColumnType nativeTypeToColumnType(int type) {
  if (type == _tablestoreJs.PrimaryKeyType.INTEGER) {
    return TsColumnType.integer;
  } else if (type == _tablestoreJs.PrimaryKeyType.STRING) {
    return TsColumnType.string;
  } else if (type == _tablestoreJs.PrimaryKeyType.BINARY) {
    return TsColumnType.binary;
  }
  throw 'type $type not supported';
}

TsTableDescription tableDescriptionFromNative(dynamic nativeDesc) {
  if (nativeDesc != null) {
    var nativeDescObject = nativeDesc as _TsClientTableDescription;
    var nativeTableMeta = nativeDescObject.tableMeta;
    if (nativeTableMeta != null) {
      List<TsPrimaryKey> primaryKeys;
      var nativePrimaryKeys = tableMetaPrimaryKeys(nativeTableMeta);
      if (nativePrimaryKeys != null) {
        primaryKeys = <TsPrimaryKey>[];
        nativePrimaryKeys.forEach((element) {
          primaryKeys.add(TsPrimaryKey(
              type: nativeTypeToColumnType(element.type), name: element.name));
        });
      }
      var tableMeta = TsTableDescriptionTableMeta(
          tableName: nativeTableMeta.tableName, primaryKeys: primaryKeys);
      return TsTableDescription(tableMeta: tableMeta);
//
    }
  }
  return null;
}

class TablestoreNode with TablestoreMixin implements Tablestore {
  PrimaryKeyTypeJs get primaryKeyType => _tablestoreJs.PrimaryKeyType;

  @override
  TsClient client({TsClientOptions options}) {
    var nativeClient = callConstructor(_tablestoreJs.Client, [
      _TsClientOptionsJs(
          accessKeyId: options.accessKeyId,
          secretAccessKey: options.secretAccessKey,
          endpoint: options.endpoint,
          instancename: options.instanceName)
    ]);
    if (nativeClient == null) {
      return null;
    }

    // devPrint('tablestoreJs: ${jsObjectKeys(_tablestoreJs)}');
    //  [util, rowExistenceExpectation, Direction, UpdateType, BatchWriteType, ReturnType, DefinedColumnType, PrimaryKeyType, PrimaryKeyOption,
    //  IndexUpdateMode, IndexType, INF_MIN, INF_MAX, PK_AUTO_INCR, Long, plainBufferConsts, plainBufferCrc8, PlainBufferInputStream,
    //  PlainBufferOutputStream, PlainBufferCodedInputStream, PlainBufferCodedOutputStream, PlainBufferBuilder, LogicalOperator, ColumnConditionType,
    //  ComparatorType, RowExistenceExpectation, ColumnCondition, CompositeCondition, SingleColumnCondition, Condition, ColumnPaginationFilter,
    //  encoder, decoder, Config, Endpoint, HttpRequest, HttpResponse, HttpClient, SequentialExecutor, EventListeners, Request, Response,
    //  Signer, events, NodeHttpClient, RetryUtil, DefaultRetryPolicy, Client, QueryType, ScoreMode, SortOrder, SortMode, FieldType, ColumnReturnType, GeoDistanceType, IndexOptions, QueryOperator]
    // Key types: {INTEGER: 1, STRING: 2, BINARY: 3}
    // devPrint('Key types: ${jsObjectAsMap(getProperty(_tablestoreJs, 'PrimaryKeyType'))}');

    return TsClientNode(nativeClient);
  }

  @override
  String toString() {
    return 'TablestoreNode()';
  }
}

final _tablestoreJs = require('tablestore') as _TablestoreJs;
/*

import 'package:node_interop/node_interop.dart';
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_js_utils/js_utils.dart';

@JS()
@anonymous
class _HttpResponseJs {
  external void send(String body);
}

@JS()
@anonymous
class _HttpReqJs {
  external String get url;

  external Map<String, dynamic> get queries;
}

@JS()
@anonymous
class _HttpContextJs {
  external Map<String, dynamic> get credentials;
}

typedef _GetBodyFn = dynamic Function(dynamic req, [dynamic option]);

_GetBodyFn _getRawBodyFn = require('raw-body');


// Example
var getRawBody = require('raw-body')
getRawBody(request, function(err, data){
  var body = data
})



// ["requestId","credentials","function","service","region","accountId","logger","retryCount"]
class FcHttpContextJs implements FcHttpContext {
  final _HttpContextJs native;

  FcHttpContextJs(this.native);

  Map<String, dynamic> get credentials => jsObjectAsMap(native.credentials);

  @override
  String toString() {
    var map = <String, dynamic>{
      'credentials': credentials,
    };
    return map.toString();
  }
}

// ["_events","_eventsCount","_maxListeners","method","clientIP","url","path","queries","headers","getHeader"
class FcHttpRequestJs implements FcHttpRequest {
  final _HttpReqJs req;
  Future _rawBody;

  FcHttpRequestJs(this.req);

  Future getRawBody() {
    return _rawBody ??= promiseToFuture(_getRawBodyFn(req));
  }

  Future _getRawBody({bool encoding}) {
    return _rawBody ??=
        promiseToFuture(_getRawBodyFn(req, jsify({'encoding': encoding})));
  }

  Future<String> getBodyString() async {
    var buff = await _getRawBody(encoding: true);
    // print('rawbody ${buff.runtimeType}');
    return buff.toString();
  }

  Map<String, dynamic> get queries {
    return jsObjectAsMap(getProperty(req, 'queries'));
  }

  String get url => req.url;

  String get path => getProperty(req, 'path');

  String get method => getProperty(req, 'method');

  dynamic get headers => getProperty(req, 'headers');

  @override
  String toString() {
    var map = <String, dynamic>{
      'queries': queries,
      'url': url,
      'path': path,
      'method': method,
      //'headers': headers
    };
    return map.toString();
  }
}

class FcHttpResponseJs implements FcHttpResponse {
  final _HttpResponseJs impl;

  FcHttpResponseJs(this.impl);

  @override
  void sendString(String text) {
    // var sendResponse =
    // callMethod(impl, 'send', [text]);
    impl.send(text);
  }

  void setStatusCode(int statusCode) {
    // to call first
    // var sendResponse =
    callMethod(impl, 'setStatusCode', [statusCode]);
  }

  void setHeader(String key, String value) {
    // to call first
    // var sendResponse =
    callMethod(impl, 'setHeader', [key, value]);
  }

  void setContentTypeJson() {
    setHeader('Content-Type', 'application/json');
  }
//response.setStatusCode(200);
//response.setHeader('content-type', 'application/json');
}
*/
