import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:tekartik_common_utils/env_utils.dart';

var _env = platform.environment;
TsClientOptions _tsClientOptionsFromEnv;

TsClientOptions getTsClientOptionsFromEnv(Map<String, String> env) {
  var endpoint = env['endpoint'];
  var accessKeyId = env['accessKeyId'];
  var secretAccessKey = env['secretAccessKey'];
  var instanceName = env['instanceName'];
  if (endpoint == null) {
    print('Missing endpoint env variable');
    return null;
  }
  if (accessKeyId == null) {
    print('Missing accessKeyId env variable');
    return null;
  }
  if (instanceName == null) {
    print('Missing instanceName env variable');
    return null;
  }
  if (secretAccessKey == null) {
    print('Missing secretAccessKey env variable');
    return null;
  }
  return TsClientOptions(
      endpoint: endpoint,
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
      instanceName: instanceName);
}

TsClientOptions get tsClientOptionsFromEnv => _tsClientOptionsFromEnv ??= () {
      if (isRunningAsJavascript) {
        return getTsClientOptionsFromEnv(_env);
      } else {
        // io sim
        return TsClientOptions(
            endpoint: 'local', accessKeyId: null, secretAccessKey: null);
      }
    }();
