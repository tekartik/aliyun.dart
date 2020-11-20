import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';
import 'package:tekartik_aliyun_oss_fs/oss_fs_io.dart';
import 'package:tekartik_aliyun_oss_fs/oss_fs_io.dart' show ossServiceFsIo;
import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:tekartik_aliyun_oss_node/oss_node.dart' show ossServiceNode;
import 'package:tekartik_common_utils/env_utils.dart';

export 'package:tekartik_aliyun_oss_fs/oss_fs.dart'
    show ossServiceFsMemory, newOssServiceFsMemory, debugAliyunOss;

OssService get ossServiceUniversal =>
    isRunningAsJavascript ? ossServiceNode : ossServiceFsIo;
