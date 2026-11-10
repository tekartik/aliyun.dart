/// One Aliyun OSS service for the Dart VM (a file system mock) and nodejs
/// (the real OSS): [ossServiceUniversal], the memory mock
/// ([newOssServiceMemory]) and the re-exported `tekartik_aliyun_oss` API.
library;

export 'package:tekartik_aliyun_oss/oss.dart';
export 'package:tekartik_aliyun_oss_fs/oss_fs.dart'
    show ossServiceMemory, newOssServiceMemory, debugAliyunOss;
export 'package:tekartik_aliyun_oss_fs/oss_fs_io.dart' show ossServiceFsIo;
export 'package:tekartik_aliyun_oss_node/oss_node.dart' show ossServiceNode;

export 'src/oss_universal.dart' show ossServiceUniversal;
