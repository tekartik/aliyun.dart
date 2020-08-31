/*void main() {
  print('Hello');
}
*/
import 'dart:convert';

import 'package:tekartik_aliyun_fc/fc.dart';
import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';

// var getRawBody = require('raw-body');
/*
exports.hello = (event, context, callback) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello!' }),
  };

  callback(null, response);
};
 */

//jsCon
void main() {
  print('Print from dartjs');
  exportHttpHandler((FcHttpRequest httpRequest, FcHttpResponse httpResp,
      FcHttpContext httpContext) async {
    /*
    httpResp.setStatusCode(200);
    // First
    httpResp.setContentTypeJson();
    httpResp.setHeader('x-test', 'x-value');

     */

    // Handle recursive objects
    /*
    var reqMap = <String, dynamic>{};
    for (var key in jsObjectKeys(req)) {
      /*
      try {
        var value = getProperty(req, key);
        reqMap[key] = value;
      } catch (e) {
        reqMap[key] = 'Error: $e';
      }*/
      /*
      if (jsIsCollection(value)) {
        // recursive
        value = jsObjectToCollection(value,
            depth: depth == null ? null : depth - 1);
      }
      map[key] = value;

       */
    }

     */
    var map = {
      'version': 1,
      'tag': 'v1',
      //'body': 'body'
      //'body': await httpReq.getBodyString(),
      //'rawBodyType': (await httpReq.getRawBody())?.runtimeType?.toString(),
      //'req': jsObjectKeys(req),
      //'httpReq': httpReq.toString(),
      //'resp': jsObjectAsMap(resp),
      //'contextKeys': jsObjectKeys(context),
      //'context': httpContext.toString(),
    };
    httpResp.sendString(jsonEncode(map));
    //resp.send('Hello from dartjs');
  });
  /*
  module.exports['handler'] = (req, resp, callback) {
    
  }*/
}
