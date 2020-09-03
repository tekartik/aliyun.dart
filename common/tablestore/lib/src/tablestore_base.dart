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

enum TsColumnType {
  integer,
  string,
  binary,
}

class TsPrimaryKey {
  final String name;
  final TsColumnType type;

  TsPrimaryKey({this.name, this.type});

  @override
  String toString() => 'pk($name, ${type.toString().split('.').last})';
}

class TsTableCreateOption {
  String name;
  List<TsPrimaryKey> primaryKeys;
}

class TsTableDescriptionTableMeta {
  final String tableName;
  List<TsPrimaryKey> primaryKeys;

  TsTableDescriptionTableMeta({this.tableName, this.primaryKeys});
}

// Out
class TsTableDescription {
  final TsTableDescriptionTableMeta tableMeta;

  TsTableDescription({this.tableMeta});

  @override
  String toString() =>
      'name ${tableMeta.tableName}, primaryKeys: ${tableMeta.primaryKeys}';
}

abstract class TsClient {
  Future<List<String>> listTableNames();
  Future deleteTable(String name);

  Future createTable(String tableName);

  Future<TsTableDescription> describeTable(String tableName);
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
