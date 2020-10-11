import 'package:meta/meta.dart';
import 'package:tekartik_aliyun_tablestore/src/ts_row.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

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

  Future createTable(String tableName, TsTableDescription description);

  Future<TsTableDescription> describeTable(String tableName);

  Future<TsPutRowResponse> putRow(TsPutRowRequest request);

  Future<TsUpdateRowResponse> updateRow(TsUpdateRowRequest request);

  Future<TsGetRowResponse> getRow(TsGetRowRequest request);

  Future<TsBatchGetRowsResponse> batchGetRows(TsBatchGetRowsRequest request);

  Future<TsBatchWriteRowsResponse> batchWriteRows(
      TsBatchWriteRowsRequest request);

  Future<TsDeleteRowResponse> deleteRow(TsDeleteRowRequest request);

  Future<TsGetRangeResponse> getRange(TsGetRangeRequest request);

  Future<TsStartLocalTransactionResponse> startLocalTransaction(
      TsStartLocalTransactionRequest request);
}

mixin TsClientMixin implements TsClient {
  @override
  Future<List<String>> listTableNames() =>
      throw UnsupportedError('listTableNames');
}
