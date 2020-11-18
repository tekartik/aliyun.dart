import 'dart:js';
import 'dart:js_util';

import 'package:tekartik_aliyun_oss_node/oss_service.dart';
import 'package:tekartik_aliyun_oss_node/src/oss_interop.dart';

import 'import.dart';
import 'oss_bucket_node.dart';
import 'oss_common_node.dart';

final ossServiceNode = OssServiceNode();

class OssServiceNode with OssServiceMixin implements OssServiceNodeCommon {
  @override
  OssClient client({OssClientOptions options}) {
    var nativeClient = ossNewClient(OssClientOptionsJs(
        accessKeyId: options.accessKeyId,
        accessKeySecret: options.accessKeySecret,
        endpoint: options.endpoint));
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

    return OssClientNode(nativeClient);
  }

  @override
  String toString() {
    return 'TablestoreNode()';
  }
/*
  @override
  TsConstantPrimaryKey get primaryKeyType => tablestoreJs.PrimaryKeyType;

  @override
  TsConstantRowExistenceExpectation get rowExistenceExpectation =>
      tablestoreJs.RowExistenceExpectation;

  @override
  TsConstantReturnType get returnType => tablestoreJs.ReturnType;

  @override
  TsConstantComparatorType get comparatorType => tablestoreJs.ComparatorType;

  @override
  TsConstantLogicalOperator get logicalOperator => tablestoreJs.LogicalOperator;

  @override
  final long = TsNodeLongClassImpl();

  @override
  TsConstantDirection get direction => tablestoreJs.Direction;
}
*/
}

class OssClientNode with OssClientMixin implements OssClient {
  final OssClientJs native;

  OssClientNode(this.native);

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
  Future<List<OssBucket>> listBuckets() async {
    var nativeResponse =
        await _nativeOperation<OssClientListBucketsResponseJs>(() async {
      var result = await promiseToFuture(native.listBuckets(
        _debugNativeRequestParams(
            'listBuckets', OssClientListBucketsParamsJs()),
      )) as OssClientListBucketsResponseJs;
      return result;
    });
    // Need to wrap result first
    return wrapNativeBuckets(List.from(nativeResponse.buckets));
  }

  @override
  String toString() => 'OssClientNode()';

  final _retryCount = 3;

  /// The return value is native
  ///
  /// The error is a TablestoreNodeException
  // ignore: unused_element
  Future<T> _nativeOperationWithCallback<T>(
      dynamic Function(Function callback) action) async {
    // 3 tests before aborting
    for (var i = 0; i < _retryCount; i++) {
      try {
        return await _nativeSingleOperationWithCallback(action);
      } catch (e) {
        // Do not retry if reponse says so
        if (e is OssExceptionNode && !e.retryable) {
          rethrow;
        }
        // Retry right away then in 1s
        var delay = i * 1000;
        if (i < _retryCount - 1) {
          if (debugAliyunOss) {
            print('retrying in $delay');
          }
          await sleep(delay);
        } else {
          break;
        }
      }
    }
    throw OssExceptionNode(message: 'timeout');
  }

  /// The return value is native
  ///
  /// The error is a TablestoreNodeException
  Future<T> _nativeOperation<T>(FutureOr<T> Function() action) async {
    // 3 tests before aborting
    for (var i = 0; i < _retryCount; i++) {
      try {
        return await action();
      } catch (e) {
        // Do not retry if reponse says so
        if (e is OssExceptionNode && !e.retryable) {
          rethrow;
        }
        // Retry right away then in 1s
        var delay = i * 1000;
        if (i < _retryCount - 1) {
          if (debugAliyunOss) {
            print('retrying in $delay');
          }
          await sleep(delay);
        } else {
          break;
        }
      }
    }
    throw OssExceptionNode(message: 'timeout');
  }

  /// The return value is native
  ///
  /// The error is a TablestoreNodeException
  Future<T> _nativeSingleOperationWithCallback<T>(
      dynamic Function(Function callback) action) async {
    var completer = Completer<T>();
    try {
      action(allowInterop((err, data) {
        if (err != null) {
          if (debugAliyunOss) {
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
          if (debugAliyunOss) {
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
    if (debugAliyunOss) {
      print('TSs: $method ${nativeDataToDebugString(params)}');
    }
    return params;
  }
}
