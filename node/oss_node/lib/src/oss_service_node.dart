import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:tekartik_aliyun_oss_node/src/oss_interop.dart';

import 'oss_client_node.dart';
import 'oss_common_node.dart';

OssService ossServiceNode = OssServiceNode();

class OssServiceNode with OssServiceMixin implements OssServiceNodeCommon {
  @override
  OssClient client({OssClientOptions? options}) {
    var nativeClient = ossNewClient(OssClientOptionsJs(
        accessKeyId: options!.accessKeyId,
        accessKeySecret: options.accessKeySecret,
        endpoint: options.endpoint));

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
