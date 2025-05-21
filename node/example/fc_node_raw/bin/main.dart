// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:js';
import 'dart:js_util' as jsu;

import 'package:node_interop/node_interop.dart' as node;

void main() {
  print('Print from dartjs');
  jsu.setProperty(
    node.exports,
    'handler',
    allowInterop((dynamic req, dynamic resp, dynamic context) async {
      var map = {'version': 1, 'url': jsu.getProperty(req, 'url')};
      jsu.callMethod(resp, 'send', [jsonEncode(map)]);
    }),
  );
}
