import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';
import 'package:tekartik_aliyun_oss_node/environment_client.dart';
import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';
import 'package:tekartik_aliyun_oss_universal/src/import.dart';

OssClient get ossClientTest => ossClientOptionsFromEnv != null
    ? ossServiceUniversal.client(options: ossClientOptionsFromEnv)
    : null;

bool get isLocalTest => !isRunningAsJavascript;

OssClientOptions _ossClientOptionsFromEnv;

OssClientOptions get ossClientOptionsFromEnv =>
    _ossClientOptionsFromEnv ??= () {
      if (isRunningAsJavascript) {
        return ossNodeClientOptionsFromEnv;
      } else {
        // io sim
        return OssClientOptionsFs()..rootPath = '.dart_tool/oss_fs_io';
      }
    }();
