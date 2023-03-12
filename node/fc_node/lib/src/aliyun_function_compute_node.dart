import 'dart:js';
import 'dart:js_util' as jsu;
import 'package:node_interop/node_interop.dart' as node;
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_aliyun_fc_node/fc_interop.dart';

class AliyunFunctionComputeNode implements AliyunFunctionCompute {
  @override
  void exportHttpHandler(FcHttpHandler handler, {String name = 'handler'}) {
    jsu.setProperty(node.exports as Object, name, allowInterop(
        (HttpReqJs req, HttpResponseJs resp, HttpContextJs context) async {
      var httpReq = FcHttpRequestNode(req);
      var httpResp = FcHttpResponseNode(resp);
      var httpContext = FcHttpContextNode(context);
      //httpResp.sendString(jsonEncode({'test': 'value'}));
      handler(httpReq, httpResp, httpContext);
    }));
  }
}

final aliyunFunctionComputeNode = AliyunFunctionComputeNode();
