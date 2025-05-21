import 'package:collection/collection.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_shim.dart';

TsNodeCommon get tsNodeCommon => tsNodeCommonShim;

// Node only
class TsArrayHack<T> {
  final Iterable<T> list;

  TsArrayHack(this.list);

  // Convert to javascript!
  dynamic toJs(dynamic Function(dynamic) jsify) =>
      throw UnsupportedError('toJs');

  @override
  bool operator ==(Object other) {
    if (other is TsArrayHack) {
      return const DeepCollectionEquality().equals(
        list.toList(),
        other.list.toList(),
      );
    }
    return false;
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(list.toList());
}
