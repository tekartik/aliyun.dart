/// Aliyun OSS on a file system: [ossServiceMemory], [newOssServiceMemory]
/// (in memory, every platform) and [OssClientOptionsFs] (root path). Re-exports
/// the `tekartik_aliyun_oss` API.
library;

export 'package:tekartik_aliyun_oss/oss.dart';

export 'src/oss_client_fs.dart' show OssClientOptionsFs;
export 'src/oss_service_fs.dart'
    show
        ossServiceFsMemory,
        // ignore: deprecated_member_use_from_same_package
        newOssServiceFsMemory,
        ossServiceMemory,
        newOssServiceMemory;
