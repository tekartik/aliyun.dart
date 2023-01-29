@JS()
library tekartik_tablestore_node.lib.src.js_note_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as util;
import 'package:tekartik_aliyun_tablestore/tablestore.dart';

@JS('JSON.stringify')
external String stringify(Object obj);

@JS('Object.keys')
external List<String> objectKeys(Object? obj);

@JS('Array.from')
external Object toJSArray(List source);

// {"buffer":[1,0,0,0,0,0,0,0],"offset":0}
TsValueLong? dartifyValueLong(Object jsObject) {
  if (util.hasProperty(jsObject, 'offset')) {
    try {
      if (util.getProperty<Object?>(jsObject, 'buffer') is Iterable) {
        return TsValueLong.fromString(jsObject.toString());
      }
    } on NoSuchMethodError {
      // so it's not a JsDate!
      return null;
    }
  }
  return null;
}
