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

// Only for valid js int(s)
class _TsValueLongNumber implements TsValueLong {
  final int value;

  _TsValueLongNumber(this.value);

  @override
  int toNumber() => value;

  @override
  String toString() => value.toString();
}

// Only for valid js int(s)
class _TsValueLongString implements TsValueLong {
  final String value;

  _TsValueLongString(this.value);

  @override
  int toNumber() => int.parse(value);

  @override
  String toString() => value;
}
