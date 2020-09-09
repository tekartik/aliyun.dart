import 'package:tekartik_aliyun_tablestore_node/src/ts_common_node.dart';

// ignore_for_file: non_constant_identifier_names
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
  TsNodeLong fromString(String value) => TsNodeLongShim(int.parse(value));
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

  @override
  TsConstantComparatorType get comparatorType => TsConstantComparatorTypeShim();

  @override
  TsConstantLogicalOperator get logicalOperator =>
      TsConstantLogicalOperatorShim();

  @override
  TsConstantDirection get direction => TsConstantDirectionShim();
}

class TsConstantComparatorTypeShim implements TsConstantComparatorType {
  @override
  int get EQUAL => 1;

  @override
  int get NOT_EQUAL => 2;

  @override
  int get GREATER_THAN => 3;

  @override
  int get GREATER_EQUAL => 4;

  @override
  int get LESS_THAN => 5;

  @override
  int get LESS_EQUAL => 6;
}

class TsConstantLogicalOperatorShim implements TsConstantLogicalOperator {
  @override
  int get NOT => 1;

  @override
  int get AND => 2;

  @override
  int get OR => 3;
}

class TsConstantDirectionShim implements TsConstantDirection {
  @override
  String get BACKWARD => 'BACKWARD';

  @override
  String get FORWARD => 'FORWARD';
}

final tsNodeCommonShim = TsNodeCommonShim();
