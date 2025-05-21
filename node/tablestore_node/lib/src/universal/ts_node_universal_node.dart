import 'package:collection/collection.dart';
import 'package:tekartik_aliyun_tablestore_node/src/interop/utils_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_tablestore.dart';

TsNodeCommon get tsNodeCommon => tablestoreNode;

// Experiment array that will be converted as a map to support
// for..in
class TsArrayHack<T> {
  final Iterable<T> list;

  TsArrayHack(this.list);

  // Convert to javascript!
  dynamic toJs(dynamic Function(dynamic) jsify) {
    var wrapper = JsArrayWrapper<Object?>();
    for (var item in list) {
      wrapper.add(tsJsify(item));
    }
    return wrapper.native;
  }

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
