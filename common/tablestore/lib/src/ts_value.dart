import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/model/model.dart';

Model blobToDebugValue(Uint8List bytes) =>
    Model({'@blob': base64Encode(bytes)});

// Can be of any type TsValue, double, String but not int!
dynamic tsValueToDebugValue(dynamic value) {
  assert(
      (value == null ||
          value is TsValue ||
          value is String ||
          value is Uint8List ||
          value is double),
      'value $value (type ${value?.runtimeType} not supported');
  if (value is TsValueBase) {
    return value.toDebugMap();
  } else if (value is Uint8List) {
    return blobToDebugValue(value);
  }
  return value;
}

abstract class TsValue {}

abstract class TsValueBase implements TsValue {
  @mustCallSuper
  Model toDebugMap() => Model();
}

// Can be implemented too
abstract class TsValueLong extends TsValueBase {
  // From caller only
  factory TsValueLong.fromNumber(int value) => _TsValueLongNumber(value);
  // From caller only
  factory TsValueLong.fromString(String value) => _TsValueLongString(value);
  // Convert to int
  int toNumber();
  @override
  String toString();
}

class TsValueInfinite implements TsValueBase {
  final String _label;
  const TsValueInfinite._(this._label);
  static const min = TsValueInfinite._('INF_MIN');
  static const max = TsValueInfinite._('INF_MAX');
  @override
  String toString() => _label;

  @override
  Model toDebugMap() => Model({
        '@infinite': this == min
            ? 'min'
            : (this == max)
                ? 'max'
                : throw UnsupportedError('TsValueInfinite($_label)')
      });
}

mixin _TsValueLongMixin implements TsValueLong {
  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    if (other is TsValueLong) {
      return other.toString() == toString();
    }
    return false;
  }

  @override
  Model toDebugMap() => Model({'@long': toString()});
}

// Only for valid js int(s)
class _TsValueLongNumber with _TsValueLongMixin {
  final int value;

  _TsValueLongNumber(this.value);

  @override
  int toNumber() => value;

  @override
  String toString() => value.toString();
}

// Only for valid js int(s)
class _TsValueLongString with _TsValueLongMixin {
  final String value;

  _TsValueLongString(this.value);

  @override
  int toNumber() => int.parse(value);

  @override
  String toString() => value;
}
