import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';

class TsConstantPrimaryKeyShim implements TsConstantPrimaryKey {
  @override
  int get INTEGER => 1;

  @override
  int get STRING => 2;
  @override
  int get BINARY => 3;
}

class TsConstantRowExistenceExpectationShim
    implements TsConstantRowExistenceExpectation {
  @override
  int get IGNORE => 0;

  @override
  int get EXPECT_EXIST => 1;

  @override
  int get EXPECT_NOT_EXIST => 2;
}

class TsConstantReturnTypeShim implements TsConstantReturnType {
  @override
  int get NONE => 0;

  @override
  int get Primarykey => 1;
  @override
  int get AfterModify => 2;
}

class TsNodeLongShim implements TsNodeLong {
  final int value;

  TsNodeLongShim(this.value);
  @override
  int toNumber() => value;

  @override
  String toString() => value.toString();
}

class TsNodeLongClassShim implements TsNodeLongClass {
  @override
  TsNodeLong fromNumber(int value) => TsNodeLongShim(value);

  @override
  TsNodeLong fromText(String value) => TsNodeLongShim(int.parse(value));
}

class TsNodeCommonShim implements TsNodeCommon {
  @override
  final primaryKeyType = TsConstantPrimaryKeyShim();

  @override
  final rowExistenceExpectation = TsConstantRowExistenceExpectationShim();

  @override
  final returnType = TsConstantReturnTypeShim();

  @override
  // TODO: implement long
  TsNodeLongClass get long => throw UnimplementedError();
}

final tsNodeCommonShim = TsNodeCommonShim();
