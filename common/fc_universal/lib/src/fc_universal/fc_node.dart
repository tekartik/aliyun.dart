import 'dart:js';
import 'dart:js_util';

import 'package:node_interop/node_interop.dart';

import 'package:tekartik_aliyun_fc_node/fc_interop.dart';
import 'package:tekartik_aliyun_fc_universal/src/fc_universal/fc_common.dart';

/// Can be called only once
void exportHttpHandler(FcHttpHandler handler, {String name = 'handler'}) {
  setProperty(exports, name,
      allowInterop((dynamic req, dynamic resp, dynamic context) async {
    var httpReq = FcHttpRequestJs(req);
    var httpResp = FcHttpResponseJs(resp);
    var httpContext = FcHttpContextJs(context);
    //httpResp.sendString(jsonEncode({'test': 'value'}));
    handler(httpReq, httpResp, httpContext);
  }));
}
