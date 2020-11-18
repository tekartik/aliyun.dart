import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:tekartik_common_utils/env_utils.dart';

import 'oss_service.dart';

var _env = platform.environment;
OssClientOptions _tsClientOptionsFromEnv;

OssClientOptions getOssClientOptionsFromEnv(Map<String, String> env) {
  var endpoint = env['endpoint'];
  var accessKeyId = env['accessKeyId'];
  var accessKeySecret = env['accessKeySecret'];
  if (endpoint == null) {
    print('Missing endpoint env variable');
    return null;
  }
  if (accessKeyId == null) {
    print('Missing accessKeyId env variable');
    return null;
  }
  if (accessKeySecret == null) {
    print('Missing accessKeySecret env variable');
    return null;
  }
  return OssClientOptions(
    endpoint: endpoint,
    accessKeyId: accessKeyId,
    accessKeySecret: accessKeySecret,
  );
}

OssClientOptions get ossClientOptionsFromEnv => _tsClientOptionsFromEnv ??= () {
      if (isRunningAsJavascript) {
        return getOssClientOptionsFromEnv(_env);
      } else {
        // io sim
        return OssClientOptions(
            endpoint: 'local', accessKeyId: null, accessKeySecret: null);
      }
    }();
