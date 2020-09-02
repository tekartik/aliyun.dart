import 'package:meta/meta.dart';

/// Table store exception
class TsException implements Exception {
  final String message;

  TsException(this.message);
}

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
  Future deleteTable(String name);

  Future createTable(String tableName);
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
