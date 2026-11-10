// ignore_for_file: deprecated_member_use
@TestOn('node')
library;

import 'dart:js_util' as jsu;

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/interop/utils_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_common.dart';
import 'package:test/test.dart';

/// The native column condition of [condition] (no request is sent).
Object nativeColumnCondition(TsColumnCondition condition) {
  var params =
      tsJsify(
            toPutRowParams(
              TsPutRowRequest(
                tableName: 'test',
                primaryKey: TsPrimaryKey([TsKeyValue('key', 'value')]),
                data: TsAttributes([TsAttribute('test', 'text')]),
                condition: TsCondition(
                  rowExistenceExpectation:
                      TsConditionRowExistenceExpectation.ignore,
                  columnCondition: condition,
                ),
              ),
            ),
          )
          as Object;
  return jsu.getProperty<Object>(
    jsu.getProperty<Object>(params, 'condition'),
    'columnCondition',
  );
}

void main() {
  group('tablestore_node condition', () {
    test('double value', () {
      // A double threw StateError('Unsupported value 1.5 (double)'); the
      // sembast implementation and Tablestore (DOUBLE) accept it.
      var native = nativeColumnCondition(
        TsColumnCondition.greaterThan('price', 1.5),
      );
      expect(jsu.getProperty<Object?>(native, 'columnName'), 'price');
      expect(jsu.getProperty<Object?>(native, 'columnValue'), 1.5);
    });
    test('string, long and composite', () {
      var native = nativeColumnCondition(
        TsColumnCondition.equals('name', 'value'),
      );
      expect(jsu.getProperty<Object?>(native, 'columnValue'), 'value');
      native = nativeColumnCondition(
        TsColumnCondition.and([
          TsColumnCondition.lessThan('count', TsValueLong.fromNumber(3)),
          TsColumnCondition.greaterThanOrEquals('ratio', 0.5),
        ]),
      );
      var sub = jsu.getProperty<List>(native, 'sub_conditions');
      expect(sub, hasLength(2));
      expect(
        jsu.callMethod<Object?>(
          jsu.getProperty<Object>(sub[0] as Object, 'columnValue'),
          'toNumber',
          [],
        ),
        3,
      );
      expect(jsu.getProperty<Object?>(sub[1] as Object, 'columnValue'), 0.5);
    });
  });
}
