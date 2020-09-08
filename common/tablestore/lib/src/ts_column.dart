import 'dart:typed_data';

import 'package:tekartik_aliyun_tablestore/src/ts_value_type.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/model/model.dart';

class TsKeyValue {
  final String name;
  final dynamic value;

  TsKeyValue(this.name, this.value) {
    assert(
        (value == null ||
            value is TsValueLong ||
            value is TsValueInfinite ||
            value is String ||
            value is Uint8List ||
            value is double),
        'value $value (type ${value.runtimeType} not supported');
  }
  TsKeyValue.string(String name, String value) : this(name, value);
  TsKeyValue.int(String name, int value)
      : this(name, TsValueLong.fromNumber(value));
  TsKeyValue.long(String name, TsValueLong value) : this(name, value);
  TsKeyValue.double(String name, double value) : this(name, value);
  TsKeyValue.binary(String name, Uint8List value) : this(name, value);

  Map<String, dynamic> toDebugMap() => <String, dynamic>{name: value};

  @override
  String toString() => toDebugMap().toString();
}

class TsAttributes with ListMixin<TsAttribute> {
  final List<TsAttribute> list;

  TsAttributes(this.list);

  @override
  int length;

  @override
  TsAttribute operator [](int index) => list[index];

  @override
  void operator []=(int index, TsAttribute value) => list[index] = value;

  ModelList toDebugList() =>
      ModelList(list.map((e) => e.toDebugMap()).toList(growable: false));
}

// Read only
class TsAttribute extends TsKeyValue {
  TsAttribute(String name, value) : super(name, value);
  TsAttribute.int(String name, int value) : super.int(name, value);
  TsAttribute.long(String name, TsValueLong value) : super.long(name, value);
  TsAttribute.binary(String name, Uint8List value) : super.binary(name, value);
  TsAttribute.double(String name, double value) : super.double(name, value);
  TsAttribute.string(String name, String value) : super.string(name, value);
}
