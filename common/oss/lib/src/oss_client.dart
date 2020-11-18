import 'package:meta/meta.dart';
import 'package:tekartik_aliyun_oss/oss.dart';

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
    return {'endpoint': endpoint}.toString();
  }
}

abstract class OssClient {
  Future<List<OssBucket>> listBuckets();
}

mixin OssClientMixin implements OssClient {
  @override
  Future<List<OssBucket>> listBuckets() =>
      throw UnsupportedError('listBuckets');
}
