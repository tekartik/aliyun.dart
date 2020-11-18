@JS()
library tekartik_aliyun_oss_node.src.oss_interop;

import 'dart:js_util';

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tekartik_aliyun_oss_node/oss_service.dart';

import 'import.dart';

@JS()
@anonymous
class OssClientListBucketsParamsJs {}

@JS()
@anonymous
abstract class OssClientListBucketJs {
  String get name;
}

@JS()
@anonymous
abstract class OssClientListBucketsResponseJs {
  List get buckets;
}

/// A structure for options provided to OSS.
@JS()
@anonymous
class OssClientOptionsJs {
  external String get accessKeyId;

  external String get accessKeySecret;

  external String get endpoint;

  external factory OssClientOptionsJs(
      {String accessKeyId, String accessKeySecret, String endpoint});
}

/// Wrap a native error
OssExceptionNode wrapNativeError(dynamic err) {
  if (err is OssExceptionNode) {
    return err;
  }
  Map errMap;
  String message;
  // Try json
  try {
    errMap = jsObjectAsMap(err);
  } catch (_) {
    message = err.toString();
  }

  if (debugAliyunOss) {
    if (errMap != null) {
      print('OSS!: errMap: ${jsonEncode(errMap)}');
    } else {
      print('OSS!: err: ${nativeDataToDebugString(err)}');
    }
  }
  return OssExceptionNode(message: message, map: errMap);
}

@JS()
@anonymous
class OssClientJs {
  external Promise listBuckets(OssClientListBucketsParamsJs params);
}

/// ```javascript
/// const OSS = require('ali-oss');
///
/// const client = new OSS({
///   // The endpoint of the China (Hangzhou) region is used in this example. Specify the actual endpoint.
///   region: '<Your region>',
///   // Security risks may arise if you use the AccessKey pair of an Alibaba Cloud account to log on to OSS because the account has permissions on all API operations. We recommend that you use your RAM user's credentials to call API operations or perform routine operations and maintenance. To create a RAM user, log on to the RAM console.
///   accessKeyId: '<Your AccessKeyId>',
///   accessKeySecret: '<Your AccessKeySecret>'
/// });
/// ```
final ossServiceJs = require('ali-oss');

/// Convert a native object to a debug string
String nativeDataToDebugString(dynamic data) {
  String text;
  try {
    text = jsonEncode(jsObjectAsMap(data));
  } catch (_) {
    try {
      text = jsObjectToDebugString(data);
    } catch (_) {
      text = data.toString();
    }
  }
  return text;
}

/// New client
OssClientJs ossNewClient(OssClientOptionsJs options) {
  var nativeClient = callConstructor(ossServiceJs, [options]) as OssClientJs;
  return nativeClient;
}
