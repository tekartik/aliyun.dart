import 'dart:js';
import 'dart:js_util';

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_exception_node.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_common.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_table_common.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_table_interop.dart';

import 'import_interop.dart';
import 'interop/utils_interop.dart';

final tablestoreNode = TablestoreNode();

typedef ErrDataCallback = dynamic Function(dynamic err, dynamic data);

class TablestoreNode with TablestoreMixin implements Tablestore, TsNodeCommon {
  @override
  @override
  TsClient client({TsClientOptions? options}) {
    var nativeClient = callConstructor<Object?>(tablestoreJs!.Client, [
      TsClientOptionsJs(
          accessKeyId: options!.accessKeyId,
          secretAccessKey: options.secretAccessKey,
          endpoint: options.endpoint,
          instancename: options.instanceName)
    ]);
    // devPrint('tablestoreJs: ${jsObjectKeys(_tablestoreJs)}');
    //  [util, rowExistenceExpectation, Direction, UpdateType, BatchWriteType, ReturnType, DefinedColumnType, PrimaryKeyType, PrimaryKeyOption,
    //  IndexUpdateMode, IndexType, INF_MIN, INF_MAX, PK_AUTO_INCR, Long, plainBufferConsts, plainBufferCrc8, PlainBufferInputStream,
    //  PlainBufferOutputStream, PlainBufferCodedInputStream, PlainBufferCodedOutputStream, PlainBufferBuilder, LogicalOperator, ColumnConditionType,
    //  ComparatorType, RowExistenceExpectation, ColumnCondition, CompositeCondition, SingleColumnCondition, Condition, ColumnPaginationFilter,
    //  encoder, decoder, Config, Endpoint, HttpRequest, HttpResponse, HttpClient, SequentialExecutor, EventListeners, Request, Response,
    //  Signer, events, NodeHttpClient, RetryUtil, DefaultRetryPolicy, Client, QueryType, ScoreMode, SortOrder, SortMode, FieldType, ColumnReturnType, GeoDistanceType, IndexOptions, QueryOperator]
    // Key types: {INTEGER: 1, STRING: 2, BINARY: 3}
    // devPrint('Key types: ${jsObjectAsMap(getProperty(_tablestoreJs, 'PrimaryKeyType'))}');

    return TsClientNode(nativeClient as TsClientJs);
  }

  @override
  String toString() {
    return 'TablestoreNode()';
  }

  @override
  TsConstantPrimaryKey get primaryKeyType => tablestoreJs!.PrimaryKeyType;

  @override
  TsConstantRowExistenceExpectation get rowExistenceExpectation =>
      tablestoreJs!.RowExistenceExpectation;

  @override
  TsConstantReturnType get returnType => tablestoreJs!.ReturnType;

  @override
  TsConstantComparatorType get comparatorType => tablestoreJs!.ComparatorType;

  @override
  TsConstantLogicalOperator get logicalOperator =>
      tablestoreJs!.LogicalOperator;

  @override
  final TsNodeLongClass long = TsNodeLongClassImpl();

  @override
  TsConstantDirection get direction => tablestoreJs!.Direction;
}

class TsClientNode with TsClientMixin implements TsClient {
  final TsClientJs native;

  TsClientNode(this.native);

  void _handleError(Completer completer, dynamic err) {
    if (!completer.isCompleted) {
      var exception = wrapNativeError(err);
      completer.completeError(exception);
    }
  }

  void _handleSuccess<T>(Completer<T> completer, T data) {
    if (!completer.isCompleted) {
      completer.complete(data);
    }
  }

  @override
  Future<List<String>> listTableNames() async {
    var nativeResponse =
        await _nativeOperationWithCallback<TsClientListTableResponseJs>(
            (callback) {
      native.listTable(
          _debugNativeRequestParams('listTable', TsClientListTableParamsJs()),
          callback);
    });
    return tableNamesFromNative(nativeResponse);
  }

  @override
  Future createTable(String name, TsTableDescription description) async {
    var params = toCreateTableParams(description);
    var jsParams = tsJsify(params);
    var nativeResponse =
        await _nativeOperationWithCallback<Object?>((callback) {
      // ignore: unused_local_variable
      native.createTable(
          _debugNativeRequestParams('createTable', jsParams), callback);
    });
    print(jsObjectToDebugString(nativeResponse));
    return null;

    // devPrint(params);
    /*
    {
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

     */
  }

  @override
  String toString() {
    return 'TsClientNode()';
  }

  @override
  Future<TsTableDescription?> deleteTable(String tableName) async {
    var nativeDesc = await _nativeOperationWithCallback<Object?>((callback) {
      native.deleteTable(
          _debugNativeRequestParams(
              'deleteTable', TsClientTableParamsJs(tableName: tableName)),
          callback);
    }) as Object;
    return tableDescriptionFromNative(nativeDesc);
  }

  final _retryCount = 3;

  /// The return value is native
  ///
  /// The error is a TablestoreNodeException
  Future<T> _nativeOperationWithCallback<T>(
      dynamic Function(Function callback) action) async {
    // 3 tests before aborting
    for (var i = 0; i < _retryCount; i++) {
      try {
        return await _nativeSingleOperationWithCallback(action);
      } catch (e) {
        // Do not retry if reponse says so
        if (e is TsExceptionNode && !e.retryable) {
          rethrow;
        }
        // Retry right away then in 1s
        var delay = i * 1000;
        if (i < _retryCount - 1) {
          if (debugTs) {
            print('retrying in $delay');
          }
          await sleep(delay);
        } else {
          break;
        }
      }
    }
    throw TsExceptionNode(message: 'timeout');
  }

  /// The return value is native
  ///
  /// The error is a TablestoreNodeException
  Future<T> _nativeSingleOperationWithCallback<T>(
      dynamic Function(Function callback) action) async {
    var completer = Completer<T>();
    try {
      action(allowInterop((Object? err, Object? data) {
        if (err != null) {
          if (debugTs) {
            if (data != null) {
              try {
                print('[TS!]: (data): ${jsObjectToDebugString(data)}');
              } catch (_) {
                print('err: some data');
              }
            }
          }
          _handleError(completer, err);
        } else {
          // var response = data;
          if (debugTs) {
            print('TSr: ${nativeDataToDebugString(data)}');
          }
          _handleSuccess(completer, data);
        }
      }));
    } catch (e) {
      _handleError(completer, e);
    }
    return completer.future;
  }

  T _debugNativeRequestParams<T>(String method, T params) {
    if (debugTs) {
      print('TSs: $method ${nativeDataToDebugString(params)}');
    }
    return params;
  }

  @override
  Future<TsTableDescription> describeTable(String tableName) async {
    var nativeDesc = await _nativeOperationWithCallback<Object?>((callback) {
      native.describeTable(
          _debugNativeRequestParams(
              'describeTable', TsClientTableParamsJs(tableName: tableName)),
          callback);
    }) as Object;
    return tableDescriptionFromNative(nativeDesc);
  }

  // experimental way (keep it false...)
  final useJs = false;

  /*
  {"consumed":{"capacityUnit":{"read":1,"write":0}},"row":{"primaryKey":[{"name":"key","value":"value"}],"attributes":[{"columnName":"test","columnValue":"text","timestamp":{"buffer":[30,20,154,94,116,1,0,0],"offset":0}}]},"RequestId":"0005ae91-ac09-e850-e5c1-720b08a5216a"}
   */
  @override
  Future<TsGetRowResponse> getRow(TsGetRowRequest request) async {
    if (useJs) {
      var jsParams = toGetRowParamsJs(request);
      var nativeResponseJs =
          await _nativeOperationWithCallback<Object?>((callback) {
        native.getRow(_debugNativeRequestParams('getRow', jsParams), callback);
      });
      return getRowResponseFromNative(nativeResponseJs);
    } else {
      var params = toGetRowParams(request);
      var jsParams = tsJsify(params);
      var nativeResponseJs =
          await _nativeOperationWithCallback<Object?>((callback) {
        native.getRow(_debugNativeRequestParams('getRow', jsParams), callback);
      });
      return getRowResponseFromNative(nativeResponseJs);
    }
  }

  @override
  Future<TsPutRowResponse> putRow(TsPutRowRequest request) async {
    var params = toPutRowParams(request);
    var jsParams = tsJsify(params);

    var nativeResponseJs =
        await _nativeOperationWithCallback<Object?>((callback) {
      native.putRow(_debugNativeRequestParams('putRow', jsParams), callback);
    });
    return putRowResponseFromNative(nativeResponseJs);
  }

  @override
  Future<TsDeleteRowResponse> deleteRow(TsDeleteRowRequest request) async {
    var params = toDeleteRowParams(request);
    var jsParams = tsJsify(params);

    var nativeResponseJs =
        await _nativeOperationWithCallback<Object?>((callback) {
      native.deleteRow(
          _debugNativeRequestParams('deleteRow', jsParams), callback);
    });
    return deleteRowResponseFromNative(nativeResponseJs);
  }

  @override
  Future<TsGetRangeResponse> getRange(TsGetRangeRequest request) async {
    var params = toGetRangeParams(request);
    var jsParams = tsJsify(params);
    var nativeResponseJs =
        await _nativeOperationWithCallback<Object?>((callback) {
      native.getRange(
          _debugNativeRequestParams('getRange', jsParams), callback);
    });
    return getRangeResponseFromNative(nativeResponseJs as TsGetRangeResponseJs);
  }

  @override
  Future<TsBatchGetRowsResponse> batchGetRows(
      TsBatchGetRowsRequest request) async {
    if (useJs) {
      // tmp exp
      var jsParams = toBatchGetRowParamsJs(request);
      var responseJs = await _nativeOperationWithCallback<Object?>((callback) {
        _debugNativeRequestParams('batchGetRow', jsParams);
        callMethod(native, 'batchGetRow', [jsParams, callback]);
      });
      return TsBatchGetRowsResponseNode(responseJs as TsBatchGetRowResponseJs);
    } else {
      var params = toBatchGetRowsParams(request);
      var jsParams = tsJsify(params);
      var responseJs = await _nativeOperationWithCallback<Object?>((callback) {
        native.batchGetRow(
            _debugNativeRequestParams('batchGetRow', jsParams), callback);
      });
      return TsBatchGetRowsResponseNode(responseJs as TsBatchGetRowResponseJs);
    }
  }

  @override
  Future<TsBatchWriteRowsResponse> batchWriteRows(
      TsBatchWriteRowsRequest request) async {
    var params = toWriteRowsParams(request);
    var jsParams = tsJsify(params);
    var responseJs = await _nativeOperationWithCallback<Object?>((callback) {
      native.batchWriteRow(
          _debugNativeRequestParams('batchWriteRow', jsParams), callback);
    });
    return TsBatchWriteRowsResponseNode(
        responseJs as TsBatchWriteRowResponseJs);
  }

  @override
  Future<TsUpdateRowResponse> updateRow(TsUpdateRowRequest request) async {
    var params = toUpdateRowParams(request);
    var jsParams = tsJsify(params);

    var nativeResponseJs =
        await _nativeOperationWithCallback<Object?>((callback) {
      native.updateRow(
          _debugNativeRequestParams('updateRow', jsParams), callback);
    });
    return updateRowResponseFromNative(nativeResponseJs);
  }

  @override
  Future<TsStartLocalTransactionResponse> startLocalTransaction(
      TsStartLocalTransactionRequest request) async {
    var params = toStartLocalTransactionParams(request);
    var jsParams = tsJsify(params);

    var nativeResponseJs =
        await _nativeOperationWithCallback<Object?>((callback) {
      native.startLocalTransaction(
          _debugNativeRequestParams('startLocalTransaction', jsParams),
          callback);
    });
    return startLocalTransactionRowResponseFromNative(nativeResponseJs);
  }
}
