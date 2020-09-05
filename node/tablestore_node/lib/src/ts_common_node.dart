// {'INTEGER': 1, 'STRING': 2, 'BINARY': 3}
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

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
  TsNodeLong fromText(String value);
}

abstract class TsNodeCommon {
  TsConstantPrimaryKey get primaryKeyType;
  TsConstantRowExistenceExpectation get rowExistenceExpectation;
  TsConstantReturnType get returnType;
  TsNodeLongClass get long;
}
