import 'dart:convert';
import 'dart:js';
import 'dart:js_util';

import 'package:node_interop/node_interop.dart';

void main() {
  print('Print from dartjs');
  setProperty(exports, 'handler',
      allowInterop((dynamic req, dynamic resp, dynamic context) async {
    var map = {'version': 1, 'url': getProperty(req, 'url')};
    callMethod(resp, 'send', [jsonEncode(map)]);
  }));
}
