import 'dart:typed_data';

import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';

import 'import.dart';
import 'oss_service_fs.dart';

class OssClientFs with OssClientMixin {
  final OssServiceFs service;
  final OssClientOptions options;

  String get rootPath => (options as OssClientOptionsFs).rootPath;

  FileSystem get fs => service.fs;

  /// if init is needed later
  Future<FileSystem> _fsReady;

  Future<FileSystem> get fsReady => _fsReady ??= () async {
        await root.create(recursive: true);
        return fs;
      }();

  /// Use the endpoint as the location
  String get location => options.endpoint;

  String fixPath(String path) =>
      fs.path.normalize(rootPath == null ? path : fs.path.join(rootPath, path));

  OssClientFs(
      {@required OssServiceFs service, @required OssClientOptions options})
      : service = service,
        options = options;

  Directory get root => fs.directory(fixPath('.'));

  @override
  Future<List<OssBucket>> listBuckets() async {
    var fs = await fsReady;
    var list = <OssBucket>[];
    var entities = await root.list().toList();
    for (var entity in entities) {
      if (await fs.isDirectory(entity.path)) {
        list.add(OssBucketFs(this, fs.path.basename(entity.path)));
      }
    }
    return list;
  }

  String getFsBucketPath(String name) => fixPath(name);

  void info(String message) {
    print('/oss_fs $message');
  }

  @override
  Future<OssBucket> putBucket(String name) async {
    var fs = await fsReady;
    if (debugAliyunOssFs) {
      info('putBucket($name)');
    }
    var bucketDir = fs.directory(getFsBucketPath(name));
    await bucketDir.create(recursive: true);
    return OssBucketFs(this, name);
  }

  @override
  Future<OssBucket> getBucket(String name) async {
    var fs = await fsReady;
    if (debugAliyunOssFs) {
      info('getBucket($name)');
    }
    var bucketDir = fs.directory(getFsBucketPath(name));
    if (await bucketDir.exists()) {
      return OssBucketFs(this, name);
    } else {
      return null;
    }
  }

  String getFsFilePath(String bucketName, String path) =>
      fixPath(fs.path.join(bucketName, path));

  @override
  Future<void> putAsBytes(
      String bucketName, String path, Uint8List bytes) async {
    assert(bytes != null);
    var fs = await fsReady;
    // Create parent dir
    var fsFilePath = getFsFilePath(bucketName, path);
    await fs.directory(fs.path.dirname(fsFilePath)).create(recursive: true);
    if (debugAliyunOssFs) {
      info('putAsBytes($bucketName, $path, ${bytes.length})');
    }
    await fs.file(fsFilePath).writeAsBytes(bytes);
  }

  @override
  Future<Uint8List> getAsBytes(String bucketName, String path) async {
    var fs = await fsReady;
    var fsFilePath = getFsFilePath(bucketName, path);
    try {
      return await fs.file(fsFilePath).readAsBytes();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> delete(String bucketName, String path) async {
    var fs = await fsReady;
    var fsFilePath = getFsFilePath(bucketName, path);
    try {
      if (debugAliyunOssFs) {
        info('delete($bucketName, $path)');
      }
      return await fs.file(fsFilePath).delete();
    } catch (e) {
      return null;
    }
  }
}

// Allow setting a root path
class OssClientOptionsFs extends OssClientOptions {
  String rootPath;
}
