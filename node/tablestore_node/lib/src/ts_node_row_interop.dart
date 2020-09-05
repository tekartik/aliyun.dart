@JS()
library tekartik_aliyun_tablestore_node.ts_row_interop;

import 'package:js/js.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_interop.dart';

@JS()
@anonymous
abstract class TsRowExistenceExpectationJs
    implements TsConstantRowExistenceExpectation {
  @override
  external int get IGNORE;

  @override
  external int get EXPECT_EXIST;

  @override
  external int get EXPECT_NOT_EXIST;
}

@JS()
@anonymous
abstract class TsReturnTypeJs implements TsConstantReturnType {
  @override
  external int get AfterModify;

  @override
  external int get NONE;

  @override
  external int get Primarykey;
}

@JS()
@anonymous
abstract class TsLongJs implements TsNodeLong {
  @override
  external int toNumber();

  @override
  external String toString();
}

@JS()
@anonymous
abstract class TsNodeLongClassJs implements TsNodeLongClass {
  @override
  external TsLongJs fromNumber(int value);

  @override
  external TsLongJs fromText(String value);
}

class TsNodeLongClassImpl implements TsNodeLongClass {
  @override
  TsNodeLong fromNumber(int value) {
    return tablestoreJs.Long.fromNumber(value);
  }

  @override
  TsNodeLong fromText(String value) {
    return tablestoreJs.Long.fromText(value);
  }
}

class TsGetRowParamsJs {}

class TsGetRowResponseJs {}

class TsPutRowParamsJs {}

class TsPutRowResponseJs {}
