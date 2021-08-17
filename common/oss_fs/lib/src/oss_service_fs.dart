import 'package:fs_shim/fs_memory.dart';

import 'import.dart';

bool debugAliyunOssFs = false; //devWarning(true);

class OssServiceFs with OssServiceMixin {
  final FileSystem fs;

  OssServiceFs({required this.fs});

  @override
  OssClient client({OssClientOptions? options}) {
    return OssClientFs(service: this, options: options);
  }
}

@Deprecated('Do not use')
OssService get ossServiceFsMemory => ossServiceMemory;

/// Shared in memory file Oss Service
final OssService ossServiceMemory = OssServiceFs(fs: fileSystemMemory);

/// Create a new Oss service in memory (not shared)
@Deprecated('Do not use')
OssService newOssServiceFsMemory([String? name]) => newOssServiceMemory(name);

/// Create a new Oss service in memory (not shared)
OssService newOssServiceMemory([String? name]) =>
    OssServiceFs(fs: newFileSystemMemory(name));
