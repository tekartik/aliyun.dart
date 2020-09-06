import 'package:js/js_util.dart' as util;
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_interop.dart';
import 'package:tekartik_aliyun_tablestore_node/src/ts_node_row_common.dart';

import 'js_node_interop.dart' as js;

/// Returns Dart representation from JS Object.
dynamic tsDartify(Object jsObject) {
  if (_isBasicType(jsObject)) {
    return jsObject;
  }

  // Handle list
  if (jsObject is Iterable) {
    return jsObject.map(tsDartify).toList();
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

Map<String, dynamic> dartifyMap(Object jsObject) {
  var keys = js.objectKeys(jsObject);
  var map = <String, dynamic>{};
  for (var key in keys) {
    map[key] = tsDartify(util.getProperty(jsObject, key));
  }
  return map;
}

dynamic jsifyList(Iterable list) {
  return js.toJSArray(list.map(tsJsify).toList());
}

/// Returns the JS implementation from Dart Object.
dynamic tsJsify(Object dartObject) {
  // devPrint('dart: $dartObject');
  if (_isBasicType(dartObject)) {
    return dartObject;
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
      util.setProperty(jsMap, key, tsJsify(value));
    });
    return jsMap;
  }

  if (dartObject is TsCondition) {
    return util.callConstructor(
        tablestoreJs.Condition, [tsConditionToNative(dartObject), null]);
  }

  print('Could not convert type ${dartObject?.runtimeType}, value $dartObject');
  throw ArgumentError.value(dartObject, 'dartObject', 'Could not convert');
}

/// Calls [method] on JavaScript object [jsObject].
dynamic callMethod(Object jsObject, String method, List<dynamic> args) =>
    util.callMethod(jsObject, method, args);

/// Returns `true` if the [value] is a very basic built-in type - e.g.
/// `null`, [num], [bool] or [String]. It returns `false` in the other case.
bool _isBasicType(Object value) {
  if (value == null || value is num || value is bool || value is String) {
    return true;
  }
  return false;
}
