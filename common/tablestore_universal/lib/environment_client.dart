import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';
import 'package:tekartik_common_utils/env_utils.dart';

var _env = platform.environment;
TsClientOptions _tsClientOptionsFromEnv;
TsClientOptions get tsClientOptionsFromEnv => _tsClientOptionsFromEnv ??= () {
      if (isRunningAsJavascript) {
        var endpoint = _env['endpoint'];
        if (endpoint == null) {
          print('Missing endpoint env variable in $_env');
        }
        return TsClientOptions(
            endpoint: _env['endpoint'],
            accessKeyId: _env['accessKeyID'],
            secretAccessKey: _env['accessKeySecret'],
            instanceName: _env['instanceName']);
      } else {
        // io sim
        return TsClientOptions(
            endpoint: 'local', accessKeyId: null, secretAccessKey: null);
      }
    }();
