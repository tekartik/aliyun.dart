import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_app_node_utils/node_utils.dart';

var _env = platform.environment;
TsClientOptions _tsClientOptionsFromEnv;
TsClientOptions get tsClientOptionsFromEnv => _tsClientOptionsFromEnv ??= () {
      var endpoint = _env['endpoint'];
      if (endpoint == null) {
        print('Missing endpoint env variable');
      }
      return TsClientOptions(
          endpoint: _env['endpoint'],
          accessKeyId: _env['accessKeyID'],
          secretAccessKey: _env['accessKeySecret'],
          instanceName: _env['instanceName']);
    }();
