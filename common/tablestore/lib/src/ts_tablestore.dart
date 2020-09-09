import 'package:tekartik_aliyun_tablestore/tablestore.dart';

abstract class Tablestore {
  TsClient client({TsClientOptions options});
}

mixin TablestoreMixin implements Tablestore {
  TsValueLong valueLongFromInt(int value) => TsValueLong.fromNumber(value);
  TsValueLong valueLongFromString(String value) =>
      TsValueLong.fromString(value);
}
