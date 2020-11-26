import 'package:fs_shim/fs_shim.dart';

import 'import.dart';

/// Shared in memory file Oss Service
final OssService ossServiceFsIo = OssServiceFs(fs: fileSystemIo);
