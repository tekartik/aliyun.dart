import 'package:meta/meta.dart';

/// Client options
class TsClientOptions {
  /// Aliyun access key id
  final String accessKeyId;

  /// Aliyun secret
  final String secretAccessKey;

  /// Table store endpoint
  final String endpoint;

  /// Table store instance name
  final String instanceName;

  TsClientOptions(
      {@required this.accessKeyId,
      @required this.secretAccessKey,
      @required this.endpoint,
      this.instanceName});

  @override
  String toString() {
    return {'endpoint': endpoint}.toString();
  }
}

abstract class TsClient {
  Future<List<String>> listTableNames();
}

mixin TsClientMixin implements TsClient {
  @override
  Future<List<String>> listTableNames() =>
      throw UnsupportedError('listTableNames');
}

class TsTable {}

abstract class Tablestore {
  TsClient client({TsClientOptions options});
}

mixin TablestoreMixin implements Tablestore {}
