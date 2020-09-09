import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';

TsNodeCommon get tsNodeCommon => throw UnsupportedError('tsNodeCommon');

// Node only
class TsArrayHack<T> {
  final Iterable<T> list;

  TsArrayHack(this.list);

  // Convert to javascript!
  dynamic toJs(dynamic Function(dynamic) jsify) =>
      throw UnsupportedError('toJs');
}
