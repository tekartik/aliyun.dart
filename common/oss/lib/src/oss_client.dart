import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:tekartik_aliyun_oss/oss.dart';
import 'package:tekartik_aliyun_oss/src/oss_bucket.dart';

String obfuscate(String text) {
  if (text == null) {
    return null;
  }
  var keepCount = min(4, text.length ~/ 2);
  return '${List.generate(text.length - keepCount, (_) => '*').join()}${text.substring(text.length - keepCount)}';
}

/// Client options
class OssClientOptions {
  /// Aliyun access key id
  final String accessKeyId;

  /// Aliyun secret
  final String accessKeySecret;

  /// Table store endpoint
  final String endpoint;

  OssClientOptions(
      {@required this.accessKeyId,
      @required this.accessKeySecret,
      @required this.endpoint});

  @override
  String toString() {
    return {
      'endpoint': endpoint,
      'accessKeyId': obfuscate(accessKeyId),
      'accessKeySecret': obfuscate(accessKeySecret)
    }.toString();
  }
}

abstract class OssClient {
  /// List all oss buckets
  Future<List<OssBucket>> listBuckets();

  /// Get bucket info
  Future<OssBucket> getBucket(String name);

  /// Only mocked for now
  Future<OssBucket> putBucket(String name);

  /// Put a file as bytes
  ///
  /// Throw on error
  Future<void> putAsBytes(String bucketName, String path, Uint8List bytes);

  /// Get a file as bytes
  ///
  /// null if not found.
  Future<Uint8List> getAsBytes(String bucketName, String path);

  /// Write a file as a string
  Future<void> putAsString(String bucketName, String path, String text);

  /// Read a file as a string
  Future<String> getAsString(String bucketName, String path);

  /// Delete a file
  ///
  /// ignore if not found
  Future<void> delete(String bucketName, String path);

  /// List all object in a bucket
  Future<OssListFilesResponse> list(String bucketName,
      [OssListFilesOptions options]);
}

mixin OssClientMixin implements OssClient {
  @override
  Future<List<OssBucket>> listBuckets() =>
      throw UnimplementedError('listBuckets');

  @override
  Future<OssListFilesResponse> list(String bucketName,
      [OssListFilesOptions options]) {
    throw UnimplementedError(
        'list($bucketName${options != null ? ', $options' : ''})');
  }

  @override
  Future<OssBucket> getBucket(String name) {
    throw UnimplementedError('getBucketInfo($name)');
  }

  @override
  Future<OssBucket> putBucket(String name) {
    throw UnimplementedError('putBucket($name)');
  }

  @override
  Future<void> putAsBytes(
      String bucketName, String path, Uint8List bytes) async {
    throw UnimplementedError('putAsBytes($bucketName, $path)');
  }

  @override
  Future<void> putAsString(String bucketName, String path, String text) =>
      putAsBytes(bucketName, path, Uint8List.fromList(utf8.encode(text)));

  @override
  Future<String /*?*/ > getAsString(String bucketName, String path) async {
    var bytes = await getAsBytes(bucketName, path);
    if (bytes != null) {
      return utf8.decode(bytes);
    }
    return null;
  }

  @override
  Future<Uint8List /*?*/ > getAsBytes(String bucketName, String path) {
    throw UnimplementedError('getAsBytes($bucketName, $path)');
  }

  @override
  Future<void> delete(String bucketName, String path) {
    throw UnimplementedError('delete($bucketName, $path)');
  }
}
