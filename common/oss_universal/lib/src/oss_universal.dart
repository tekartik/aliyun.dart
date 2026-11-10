import 'package:tekartik_aliyun_oss_fs/oss_fs_io.dart';
import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:tekartik_common_utils/env_utils.dart';

export 'package:tekartik_aliyun_oss_fs/oss_fs.dart'
    show ossServiceMemory, newOssServiceMemory, debugAliyunOss;

/// `ossServiceNode` when compiled to JavaScript (nodejs), `ossServiceFsIo` (a
/// file system mock) on the Dart VM.
OssService get ossServiceUniversal =>
    isRunningAsJavascript ? ossServiceNode : ossServiceFsIo;
