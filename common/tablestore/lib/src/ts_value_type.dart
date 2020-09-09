// Can be implemented too
abstract class TsValueLong {
  // From caller only
  factory TsValueLong.fromNumber(int value) => _TsValueLongNumber(value);
  // From caller only
  factory TsValueLong.fromString(String value) => _TsValueLongString(value);
  // Convert to int
  int toNumber();
  @override
  String toString();
}

class TsValueInfinite {
  final String _label;
  const TsValueInfinite._(this._label);
  static const min = TsValueInfinite._('INF_MIN');
  static const max = TsValueInfinite._('INF_MAX');
  @override
  String toString() => _label;
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
