// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:js';
import 'dart:js_util' as jsu;
import 'package:node_interop/node_interop.dart' as node;
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_aliyun_fc_node/fc_interop.dart';

/// Function Compute nodejs runtime.
class AliyunFunctionComputeNode implements AliyunFunctionCompute {
  /// Sets `exports.<name>` to a Function Compute http handler calling
  /// [handler]. The handler is awaited; an error is printed and answered
  /// with a 500 (as tekartik_aliyun_fc_http does).
  @override
  void exportHttpHandler(FcHttpHandler handler, {String name = 'handler'}) {
    jsu.setProperty(
      node.exports as Object,
      name,
      allowInterop((
        HttpReqJs req,
        HttpResponseJs resp,
        HttpContextJs context,
      ) async {
        var httpReq = FcHttpRequestNode(req);
        var httpResp = FcHttpResponseNode(resp);
        var httpContext = FcHttpContextNode(context);
        try {
          await handler(httpReq, httpResp, httpContext);
        } catch (e, st) {
          print('handler $name error: $e');
          print(st);
          try {
            httpResp.setStatusCode(500);
            await httpResp.sendString('error');
          } catch (_) {
            // Response already sent
          }
        }
      }),
    );
  }
}

/// The Function Compute nodejs runtime.
final aliyunFunctionComputeNode = AliyunFunctionComputeNode();
