import 'dart:js';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:node_interop/node_interop.dart' as node;
import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:tekartik_aliyun_oss_node/src/oss_interop.dart';

import 'import.dart';
import 'oss_bucket_node.dart';

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
        if (debugAliyunOss) {
          print('error $e');
        }
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
      log('<send>: $method ${nativeDataToDebugString(params)}');
    }
    return params;
  }

  @override
  Future<List<OssBucket>> listBuckets() async {
    var nativeResponse =
        await _nativeOperation<OssClientListBucketsResponseJs>(() async {
      var result = await promiseToFuture(native.listBuckets(
        _debugNativeRequestParams(
            'listBuckets', OssClientListBucketsParamsJs()),
      )) as OssClientListBucketsResponseJs;
      if (debugAliyunOss) {
        log('<resp>: ${nativeDataToDebugString(result)}');
      }
      /*
      try {
        devPrint(nativeDataToDebugString(result));
      } catch (e) {
        devPrint(e);
      }*/
      return result;
    });

    // Need to wrap result first
    return wrapNativeBuckets(List.from(nativeResponse.buckets));
  }

  String lastUsedBucketName;

  void useBucket(String name) {
    if (debugAliyunOss) {
      log('useBucket($name)');
    }
    native.useBucket(name);
  }

  void log(dynamic message) {
    print('/oss_node $message');
  }

  void err(dynamic message) {
    print('/oss_node ERR $message');
  }

  // Global lock for now
  final _inBucketLock = Lock();

  Future<T> inBucket<T>(String name, Future<T> Function() action) {
    return _inBucketLock.synchronized(() async {
      useBucket(name);
      return await action();
    });
  }

  @override
  Future<OssBucket> getBucket(String name) async {
    var nativeResponse =
        await _nativeOperation<OssClientGetBucketInfoResponseJs>(() async {
      var result = await promiseToFuture(
        native.getBucketInfo(_debugNativeRequestParams('getBucketinfo', name)),
      ) as OssClientGetBucketInfoResponseJs;
      return result;
    });
    // devPrint(nativeDataToDebugString(nativeResponse));
    // Need to wrap result first
    return wrapNativeBucketInfo(nativeResponse.bucket);
  }

  @override
  Future<void> putAsBytes(String bucketName, String path, Uint8List bytes) {
    return inBucket<void>(bucketName, () async {
      await _nativeOperation<void>(() async {
        var buffer = node.Buffer.from(bytes);
        if (debugAliyunOss) {
          log('<send>: put($bucketName, $path, ${bytes.length} bytes buffer');
        }
        var result = await promiseToFuture(native.put(path, buffer))
            as OssClientPutResponseJs;
        if (debugAliyunOss) {
          log('<resp>: ${nativeDataToDebugString(result)}');
        }
        //return result;
      });
      // devPrint(nativeDataToDebugString(nativeResponse));
      // Need to wrap result first
      // return wrapNativeBucketInfo(nativeResponse.bucket);
    });
  }

  @override
  Future<Uint8List> getAsBytes(String bucketName, String path) {
    return inBucket<Uint8List>(bucketName, () async {
      var nativeResponse =
          await _nativeOperation<OssClientGetResponseJs>(() async {
        if (debugAliyunOss) {
          log('<send>: get($bucketName, $path)');
        }
        try {
          var result =
              await promiseToFuture(native.get(path)) as OssClientGetResponseJs;
          if (debugAliyunOss) {
            log('<resp>: ${nativeDataToDebugString(result)}');
          }
          return result;
        } catch (e) {
          if (debugAliyunOss) {
            err('error $e getAsBytes');
          }
          // error NoSuchKeyError: The specified key does not exist.
          if (e.toString().toLowerCase().contains('nosuchkeyerror')) {
            // not found!
            return null;
          } else {
            rethrow;
          }
        }
      });
      // devPrint(nativeDataToDebugString(nativeResponse));
      // Need to wrap result first
      return nativeResponse?.res?.data as Uint8List;
    });
  }

  @override
  Future<void> delete(String bucketName, String path) {
    return inBucket<void>(bucketName, () async {
      await _nativeOperation<OssClientDeleteResponseJs>(() async {
        if (debugAliyunOss) {
          log('<send>: delete($bucketName, $path)');
        }
        var result = await promiseToFuture(native.delete(path))
            as OssClientDeleteResponseJs;
        if (debugAliyunOss) {
          log('<resp>: ${nativeDataToDebugString(result)}');
        }
        return result;
      });
    });
  }
}
