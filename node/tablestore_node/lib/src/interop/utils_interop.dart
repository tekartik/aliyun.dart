import 'dart:typed_data';

import 'package:js/js_util.dart' as util;
import 'package:node_interop/node_interop.dart' as node;
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/universal/ts_node_universal.dart';

import 'js_node_interop.dart' as js;

/// Returns Dart representation from JS Object.
dynamic tsDartifyValue(Object? jsObject) {
  // devPrint('js: ${jsObjectAsCollection(jsObject)}');
  if (_isBasicType(jsObject)) {
    return jsObject;
  }

  // Handle Buffer
  if (jsObject is Uint8List) {
    return jsObject;
  }
  // Handle list
  if (jsObject is Iterable) {
    // It is a Blob!
    // return jsObject.map(tsDartifyValue).toList();
    // No!
    throw ArgumentError.value(jsObject, 'list not supported');
  }
  var jsLong = js.dartifyValueLong(jsObject!);
  if (jsLong != null) {
    return jsLong;
  }

/*  var jsDate = js.dartifyDate(jsObject);
  if (jsDate != null) {
    return jsDate;
  }


  if (util.hasProperty(jsObject, 'firestore') &&
      util.hasProperty(jsObject, 'id') &&
      util.hasProperty(jsObject, 'parent')) {
    // This is likely a document reference – at least we hope
    // TODO(kevmoo): figure out if there is a more robust way to detect
    return DocumentReference.getInstance(jsObject);
  }

  if (util.hasProperty(jsObject, 'latitude') &&
      util.hasProperty(jsObject, 'longitude') &&
      js.objectKeys(jsObject).length == 2) {
    // This is likely a GeoPoint – return it as-is
    return jsObject as GeoPoint;
  }

  var proto = util.getProperty(jsObject, '__proto__');

  if (util.hasProperty(proto, 'toDate') &&
      util.hasProperty(proto, 'toMillis')) {
    return DateTime.fromMillisecondsSinceEpoch(
        (jsObject as TimestampJsImpl).toMillis());
  }

  if (util.hasProperty(proto, 'isEqual') &&
      util.hasProperty(proto, 'toBase64')) {
    // This is likely a GeoPoint – return it as-is
    // TODO(kevmoo): figure out if there is a more robust way to detect
    return jsObject as Blob;
  }*/

  // Assume a map then...
  return dartifyMap(jsObject);
}

Map<String, dynamic> dartifyMap(Object? jsObject) {
  var keys = js.objectKeys(jsObject);
  var map = <String, dynamic>{};
  for (var key in keys) {
    map[key] = tsDartifyValue(util.getProperty(jsObject!, key));
  }
  return map;
}

dynamic jsifyList(Iterable list) {
  return js.toJSArray(list.map(tsJsify).toList());
}

dynamic tsValueToNative(dynamic value) {
  // Test before list
  if (value is Uint8List) {
    // devPrint('blob $dartObject');
    return node.Buffer.from(value);
  }
  if (value is TsValueLong) {
    return tsValueLongToNative(value);
  }
  if (value is String) {
    return value;
  }
  throw 'Unsupported value $value (${value.runtimeType})';
}

/// Returns the JS implementation from Dart Object.
dynamic tsJsify(Object? dartObject) {
  if (_isBasicType(dartObject)) {
    return dartObject;
  }

  // Test before list
  if (dartObject is Uint8List) {
    // devPrint('blob $dartObject');
    return node.Buffer.from(dartObject);
  }
  /*if (dartObject is DateTime) {
    return TimestampJsImpl.fromMillis(dartObject.millisecondsSinceEpoch);
  }
*/
  if (dartObject is Iterable) {
    return jsifyList(dartObject);
  }

  if (dartObject is Map) {
    var jsMap = util.newObject();
    dartObject.forEach((key, value) {
      util.setProperty(jsMap as Object, key as Object, tsJsify(value));
    });
    return jsMap;
  }

  if (dartObject is TsCondition) {
    return tsConditionToNative(dartObject);
  }

  if (dartObject is TsValueLong) {
    return tsValueLongToNative(dartObject);
  }

  if (dartObject is TsValueInfinite) {
    return tsValueInfiniteToNative(dartObject);
  }

  if (dartObject is TsDirection) {
    return tsDirectionToNative(dartObject);
  }

  if (dartObject is TsWriteRowType) {
    return tsWriteRowTypeToNative(dartObject);
  }

  if (dartObject is TsArrayHack) {
    // devPrint('converting $dartObject');
    return dartObject.toJs(tsJsify);
  }

  if (dartObject is TsColumnCondition) {
    return tsColumnConditionToNative(dartObject);
  }

  print('Could not convert type ${dartObject?.runtimeType}, value $dartObject');
  throw ArgumentError.value(dartObject, 'dartObject', 'Could not convert');
}

/// Calls [method] on JavaScript object [jsObject].
dynamic callMethod(Object jsObject, String method, List<dynamic> args) =>
    util.callMethod(jsObject, method, args);

/// Returns `true` if the [value] is a very basic built-in type - e.g.
/// `null`, [num], [bool] or [String]. It returns `false` in the other case.
bool _isBasicType(Object? value) {
  if (value == null || value is num || value is bool || value is String) {
    return true;
  }
  return false;
}
