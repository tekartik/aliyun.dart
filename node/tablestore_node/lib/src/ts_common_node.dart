// {'INTEGER': 1, 'STRING': 2, 'BINARY': 3}
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

// ignore_for_file: non_constant_identifier_names

abstract class TsConstantPrimaryKey {
  int get INTEGER;

  int get STRING;

  int get BINARY;
}

// {'IGNORE': 0, 'EXPECT_EXIST': 1, 'EXPECT_NOT_EXIST': 2}
abstract class TsConstantRowExistenceExpectation {
  int get IGNORE;

  int get EXPECT_EXIST;

  int get EXPECT_NOT_EXIST;
}

//   'EQUAL': 1,
//         'NOT_EQUAL': 2,
//         'GREATER_THAN': 3,
//         'GREATER_EQUAL': 4,
//         'LESS_THAN': 5,
//         'LESS_EQUAL': 6
abstract class TsConstantComparatorType {
  int get EQUAL;

  int get NOT_EQUAL;

  int get GREATER_THAN;

  int get GREATER_EQUAL;

  int get LESS_THAN;

  int get LESS_EQUAL;
}

// {'FORWARD': 'FORWARD', 'BACKWARD': 'BACKWARD'}
abstract class TsConstantDirection {
  String get FORWARD;

  String get BACKWARD;
}

//  {'NOT': 1, 'AND': 2, 'OR': 3}
abstract class TsConstantLogicalOperator {
  int get NOT;

  int get AND;

  int get OR;
}

// {'NONE': 0, 'Primarykey': 1, 'AfterModify': 2}
abstract class TsConstantReturnType {
  int get NONE;

  int get Primarykey;

  int get AfterModify;
}

abstract class TsNodeLong implements TsValueLong {
  @override
  int toNumber();

  @override
  String toString();
}

abstract class TsNodeLongClass {
  TsNodeLong fromNumber(int value);

  TsNodeLong fromString(String value);
}

abstract class TsNodeCommon {
  TsConstantPrimaryKey get primaryKeyType;

  TsConstantRowExistenceExpectation get rowExistenceExpectation;

  TsConstantReturnType get returnType;

  TsConstantComparatorType get comparatorType;

  TsConstantLogicalOperator get logicalOperator;

  TsConstantDirection get direction;

  TsNodeLongClass get long;
}
