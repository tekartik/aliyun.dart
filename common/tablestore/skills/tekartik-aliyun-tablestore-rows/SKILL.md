---
name: tekartik-aliyun-tablestore-rows
description: >-
  Use when reading or writing Aliyun Tablestore rows from Dart with
  tekartik_aliyun_tablestore: TsClient putRow, getRow, updateRow, deleteRow,
  getRange, batchGetRows, batchWriteRows, startLocalTransaction, and the
  request/response model TsPrimaryKey, TsKeyValue, TsAttribute, TsAttributes,
  TsUpdateAttributes, TsUpdateAttributePut, TsUpdateAttributeDelete,
  TsGetRowRequest, TsPutRowRequest, TsUpdateRowRequest, TsDeleteRowRequest,
  TsGetRangeRequest, TsBatchGetRowsRequest, TsBatchWriteRowsRequest,
  TsCondition, TsConditionRowExistenceExpectation, TsColumnCondition,
  TsDirection, TsValueLong, TsValueInfinite, TsGetRow, toDebugMap and
  TsException (isConditionFailedError).
---

# Tablestore rows (tekartik_aliyun_tablestore)

Row level API of Aliyun Tablestore (OTS): every operation takes a request
object and returns a response object, all from the single library
`package:tekartik_aliyun_tablestore/tablestore.dart`. The `TsClient` comes
from an implementation package (node, sembast mock or universal); this API is
the same everywhere.

## Guidelines

* Import only `package:tekartik_aliyun_tablestore/tablestore.dart`. See the
  [tables skill](../tekartik-aliyun-tablestore-tables/SKILL.md) for the
  dependency block, `TsClientOptions` and table creation.
* A row is identified by a `TsPrimaryKey(List<TsKeyValue>)` whose values are
  in the table's primary key order. Build values with the typed constructors:
  `TsKeyValue.string(name, value)`, `TsKeyValue.int(name, value)` (wraps a
  `TsValueLong`), `TsKeyValue.long(name, TsValueLong)`,
  `TsKeyValue.double(name, value)`, `TsKeyValue.binary(name, Uint8List)`.
  The generic `TsKeyValue(name, value)` asserts the value is a
  `TsValueLong`, `TsValueInfinite`, `String`, `double` or `Uint8List` -
  a plain `int` is rejected, always wrap it.
* Columns are `TsAttribute` (same constructors: `.string`, `.int`, `.long`,
  `.double`, `.binary`) grouped in `TsAttributes([...])`. `TsAttributes` is a
  read only `List<TsAttribute>` with `toMap()` (name -> attribute) and
  `toDebugList()`.
* Writes:
  * `putRow(TsPutRowRequest(tableName:, primaryKey:, data: TsAttributes, condition:))`
    replaces the whole row.
  * `updateRow(TsUpdateRowRequest(tableName:, primaryKey:, data: TsUpdateAttributes, condition:))`
    merges: `TsUpdateAttributes([TsUpdateAttributePut(TsAttributes([...])), TsUpdateAttributeDelete(['col3', 'col4'])])`.
  * `deleteRow(TsDeleteRowRequest(tableName:, primaryKey:, condition:))`.
  * `condition` is a `TsCondition`: the ready made `TsCondition.ignore`
    (upsert), `TsCondition.expectExist` (update only),
    `TsCondition.expectNotExist` (insert only), or
    `TsCondition(rowExistenceExpectation: TsConditionRowExistenceExpectation.ignore, columnCondition: ...)`
    for a check-and-set. A failed condition throws a `TsException` with
    `isConditionFailedError` true - catch it, it is the normal way to detect
    a concurrent write.
* Reads: `getRow(TsGetRowRequest(tableName:, primaryKey:, columns:))` returns
  a `TsGetRowResponse` whose `row` is a `TsGetRow` with `exists`,
  `primaryKey` and `attributes` (both null when the row is missing - a
  missing row is not an exception). `columns` restricts the returned
  attributes.
* Ranges: `getRange(TsGetRangeRequest(tableName:, inclusiveStartPrimaryKey:, exclusiveEndPrimaryKey:, direction:, limit:, columns:, columnCondition:))`.
  Use `TsValueInfinite.min` / `TsValueInfinite.max` as key values for the
  open ends (and for the trailing keys of a multi key table), and
  `TsDirection.forward` / `TsDirection.backward` (backward means start > end).
  Paginate with `response.nextStartPrimaryKey`: when it is not null, reissue
  the request with it as `inclusiveStartPrimaryKey`.
* Batches: `batchGetRows(TsBatchGetRowsRequest(tables: [TsBatchGetRowsRequestTable(tableName:, primaryKeys:, columns:)]))`
  returns `tables`, one `List<TsBatchGetRowsResponseRow>` per requested table,
  each row carrying `isOk`, `errorCode`, `errorMessage`, `tableName`,
  `primaryKey` and `attributes`; check `isOk` per row, a failed row does not
  throw. `batchWriteRows(TsBatchWriteRowsRequest(tables: [TsBatchWriteRowsRequestTable(tableName:, rows: [...])]))`
  takes `TsBatchWriteRowsRequestPutRow`, `TsBatchWriteRowsRequestUpdateRow`
  and `TsBatchWriteRowsRequestDeleteRow` (each with `primaryKey` and an
  optional `condition`) and returns `rows` with the same per row status.
  Batches are not atomic.
* Integer values are never plain `int` on the wire: they are `TsValueLong`
  (`TsValueLong.fromNumber(int)`, `TsValueLong.fromString(String)` for values
  beyond the javascript safe range, `toNumber()` to read back). Responses
  give you `TsValueLong` for integers, `String`, `double` or `Uint8List`
  otherwise, so cast on read. `tsValueToDebugValue(value)` and the
  `toDebugMap()` extensions on the responses and on `TsGetRow` produce
  JSON-able maps (`{'@long': '1'}`, `{'@blob': '<base64>'}`) - ideal for
  logging and for `expect` in tests.
* `startLocalTransaction(TsStartLocalTransactionRequest(tableName:, primaryKey:))`
  returns a `transactionId`; the primary key must contain the partition key
  only. It is not implemented by every backend, so do not build on it.

## Examples

### Put, get and delete a row

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

Future<void> putGetDelete(TsClient client, String tableName) async {
  var key = TsPrimaryKey([TsKeyValue.string('key', 'my_row')]);

  await client.putRow(
    TsPutRowRequest(
      tableName: tableName,
      primaryKey: key,
      data: TsAttributes([
        TsAttribute.string('name', 'Hello'),
        TsAttribute.int('count', 1),
      ]),
    ),
  );

  var response = await client.getRow(
    TsGetRowRequest(tableName: tableName, primaryKey: key),
  );
  var row = response.row;
  if (row.exists) {
    var map = row.attributes!.toMap();
    var name = map['name']!.value as String;
    var count = (map['count']!.value as TsValueLong).toNumber();
    print('$name $count'); // Hello 1
    print(response.toDebugMap()); // JSON-able debug view
  }

  await client.deleteRow(
    TsDeleteRowRequest(tableName: tableName, primaryKey: key),
  );
}
```

### Insert only / update only, and the condition failure

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

/// Returns false when the row already exists.
Future<bool> insertIfAbsent(
  TsClient client,
  String tableName,
  String id,
  String value,
) async {
  try {
    await client.putRow(
      TsPutRowRequest(
        tableName: tableName,
        primaryKey: TsPrimaryKey([TsKeyValue.string('key', id)]),
        condition: TsCondition.expectNotExist,
        data: TsAttributes([TsAttribute.string('value', value)]),
      ),
    );
    return true;
  } on TsException catch (e) {
    if (e.isConditionFailedError) {
      return false;
    }
    rethrow;
  }
}

/// Merge columns, delete some others, only if the row is already there.
Future<void> patchRow(TsClient client, String tableName, String id) async {
  await client.updateRow(
    TsUpdateRowRequest(
      tableName: tableName,
      primaryKey: TsPrimaryKey([TsKeyValue.string('key', id)]),
      condition: TsCondition.expectExist,
      data: TsUpdateAttributes([
        TsUpdateAttributePut(
          TsAttributes([
            TsAttribute.int('count', 2),
            TsAttribute.string('name', 'updated'),
          ]),
        ),
        TsUpdateAttributeDelete(['obsolete1', 'obsolete2']),
      ]),
    ),
  );
}
```

### Range scan with pagination and a column condition

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

/// All rows of a single string key table, 100 at a time.
Future<List<TsGetRow>> scanAll(TsClient client, String tableName) async {
  var rows = <TsGetRow>[];
  TsPrimaryKey? start = TsPrimaryKey([
    TsKeyValue('key', TsValueInfinite.min),
  ]);
  while (start != null) {
    var response = await client.getRange(
      TsGetRangeRequest(
        tableName: tableName,
        inclusiveStartPrimaryKey: start,
        exclusiveEndPrimaryKey: TsPrimaryKey([
          TsKeyValue('key', TsValueInfinite.max),
        ]),
        direction: TsDirection.forward,
        limit: 100,
        columns: ['name'],
        // Server side filter on a non key column.
        columnCondition: TsColumnCondition.and([
          TsColumnCondition.greaterThanOrEquals('count', 1),
          TsColumnCondition.notEquals('name', 'skip'),
        ]),
      ),
    );
    rows.addAll(response.rows);
    start = response.nextStartPrimaryKey;
  }
  return rows;
}
```

### Batch get and batch write

```dart
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

Future<void> batches(TsClient client, String tableName) async {
  var key1 = TsPrimaryKey([TsKeyValue.string('key', 'batch_1')]);
  var key2 = TsPrimaryKey([TsKeyValue.string('key', 'batch_2')]);

  await client.batchWriteRows(
    TsBatchWriteRowsRequest(
      tables: [
        TsBatchWriteRowsRequestTable(
          tableName: tableName,
          rows: [
            TsBatchWriteRowsRequestPutRow(
              primaryKey: key1,
              data: TsAttributes([TsAttribute.int('test', 1)]),
            ),
            TsBatchWriteRowsRequestUpdateRow(
              primaryKey: key2,
              condition: TsCondition.ignore,
              data: TsUpdateAttributes([
                TsUpdateAttributePut(
                  TsAttributes([TsAttribute.string('test', 'two')]),
                ),
              ]),
            ),
            TsBatchWriteRowsRequestDeleteRow(
              primaryKey: TsPrimaryKey([TsKeyValue.string('key', 'gone')]),
            ),
          ],
        ),
      ],
    ),
  );

  var response = await client.batchGetRows(
    TsBatchGetRowsRequest(
      tables: [
        TsBatchGetRowsRequestTable(
          tableName: tableName,
          primaryKeys: [key1, key2],
        ),
      ],
    ),
  );
  for (var table in response.tables) {
    for (var row in table) {
      if (row.isOk) {
        print('${row.tableName} ${row.primaryKey} ${row.attributes}');
      } else {
        print('failed: ${row.errorCode} ${row.errorMessage}');
      }
    }
  }
}
```

### Big integers and binary columns

```dart
import 'dart:typed_data';

import 'package:tekartik_aliyun_tablestore/tablestore.dart';

Future<void> writeBigValues(TsClient client, String tableName) async {
  await client.putRow(
    TsPutRowRequest(
      tableName: tableName,
      primaryKey: TsPrimaryKey([
        // int is never accepted raw, wrap it.
        TsKeyValue.long('key', TsValueLong.fromNumber(1)),
      ]),
      data: TsAttributes([
        // Beyond 2^53: keep it as a string.
        TsAttribute.long('big', TsValueLong.fromString('9223372036854775807')),
        TsAttribute.binary('blob', Uint8List.fromList([1, 2, 3])),
        TsAttribute.double('ratio', 0.5),
      ]),
    ),
  );
}
```
