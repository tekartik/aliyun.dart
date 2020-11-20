import 'package:fs_shim/fs_memory.dart';

import 'import.dart';

bool debugAliyunOssFs = false; //devWarning(true);

class OssServiceFs with OssServiceMixin {
  final FileSystem fs;

  OssServiceFs({@required this.fs});
  @override
  OssClient client({OssClientOptions options}) {
    return OssClientFs(service: this, options: options);
  }
}

/// Shared in memory file Oss Service
final OssService ossServiceFsMemory = OssServiceFs(fs: fileSystemMemory);

/// Create a new Oss service in memory (not shared)
OssService newOssServiceFsMemory([String name]) =>
    OssServiceFs(fs: newFileSystemMemory(name));
