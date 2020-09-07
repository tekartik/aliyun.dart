import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:tekartik_common_utils/env_utils.dart';

var _env = platform.environment;
TsClientOptions _tsClientOptionsFromEnv;
TsClientOptions get tsClientOptionsFromEnv => _tsClientOptionsFromEnv ??= () {
      if (isRunningAsJavascript) {
        var endpoint = _env['endpoint'];
        var accessKeyId = _env['accessKeyId'];
        var secretAccessKey = _env['secretAccessKey'];
        var instanceName = _env['instanceName'];
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
      } else {
        // io sim
        return TsClientOptions(
            endpoint: 'local', accessKeyId: null, secretAccessKey: null);
      }
    }();
