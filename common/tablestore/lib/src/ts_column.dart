import 'dart:typed_data';

import 'package:cv/cv.dart';
import 'package:tekartik_aliyun_tablestore/src/ts_value.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class TsKeyValue {
  final String name;
  final Object value;

  TsKeyValue(this.name, this.value) {
    assert(
      (value is TsValueLong ||
          value is TsValueInfinite ||
          value is String ||
          value is Uint8List ||
          value is double),
      'TsKeyValue: value \'$name\': $value (type ${value.runtimeType} not supported',
    );
  }

  TsKeyValue.string(String name, String value) : this(name, value);

  TsKeyValue.int(String name, int value)
    : this(name, TsValueLong.fromNumber(value));

  TsKeyValue.long(String name, TsValueLong value) : this(name, value);

  TsKeyValue.double(String name, double value) : this(name, value);

  TsKeyValue.binary(String name, Uint8List value) : this(name, value);

  // Json
  Model toDebugMap() => asModel({name: tsValueToDebugValue(value)});

  @override
  String toString() => toDebugMap().toString();

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is TsKeyValue && (other.name == name) && (other.value == value);
}

class TsAttributes with ListMixin<TsAttribute> {
  final List<TsAttribute> list;

  TsAttributes(this.list);

  @override
  int get length => list.length;

  @override
  set length(int newLength) => throw UnsupportedError('read only');

  @override
  TsAttribute operator [](int index) => list[index];

  @override
  void operator []=(int index, TsAttribute value) =>
      throw UnsupportedError('read only');

  ModelList toDebugList() =>
      asModelList(list.map((e) => e.toDebugMap()).toList(growable: false));

  Map<String, TsAttribute> toMap() =>
      list.fold(<String, TsAttribute>{}, (map, attr) {
        return map..[attr.name] = attr;
      });
}

// Read only
class TsAttribute extends TsKeyValue {
  TsAttribute(super.name, super.value);

  TsAttribute.int(super.name, super.value) : super.int();

  TsAttribute.long(super.name, super.value) : super.long();

  TsAttribute.binary(super.name, super.value) : super.binary();

  TsAttribute.double(super.name, super.value) : super.double();

  TsAttribute.string(super.name, super.value) : super.string();
}

class TsUpdateAttributes with ListMixin<TsUpdateAttribute> {
  final List<TsUpdateAttribute> list;

  TsUpdateAttributes(this.list);

  @override
  int get length => list.length;

  @override
  set length(int newLength) => throw UnsupportedError('read only');

  @override
  TsUpdateAttribute operator [](int index) => list[index];

  @override
  void operator []=(int index, TsUpdateAttribute value) =>
      throw UnsupportedError('read only');
}

abstract class TsUpdateAttribute {}

class TsUpdateAttributePut implements TsUpdateAttribute {
  final TsAttributes attributes;

  TsUpdateAttributePut(this.attributes);
}

/// Tablestore DELETE_ALL
class TsUpdateAttributeDelete implements TsUpdateAttribute {
  final List<String> fields;

  TsUpdateAttributeDelete(this.fields);
}
