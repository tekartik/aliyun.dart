import 'dart:typed_data';

import 'package:tekartik_aliyun_tablestore/src/ts_value_type.dart';

class TsKeyValue {
  final String name;
  final dynamic value;

  TsKeyValue(this.name, this.value);
  TsKeyValue.string(String name, String value) : this(name, value);
  TsKeyValue.int(String name, int value) : this(name, value);
  TsKeyValue.long(String name, TsValueLong value) : this(name, value);
  TsKeyValue.binary(String name, Uint8List value) : this(name, value);

  Map<String, dynamic> toDebugMap() => <String, dynamic>{name: value};

  @override
  String toString() => toDebugMap().toString();
}

// Read only
class TsAttribute extends TsKeyValue {
  TsAttribute(String name, value) : super(name, value);
}
