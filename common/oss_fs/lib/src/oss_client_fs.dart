import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';
import 'package:tekartik_aliyun_oss_fs/src/oss_file_fs.dart';

import 'import.dart';
import 'oss_service_fs.dart';

class OssClientFs with OssClientMixin {
  final OssServiceFs service;
  final OssClientOptions? options;

  String? get rootPath => (options as OssClientOptionsFs?)?.rootPath;

  FileSystem get fs => service.fs;

  /// if init is needed later
  Future<FileSystem>? _fsReady;

  Future<FileSystem> get fsReady => _fsReady ??= () async {
        await root.create(recursive: true);
        return fs;
      }();

  /// Use the endpoint as the location
  String get location => options!.endpoint;

  String fixFsPath(String path) => fs.path
      .normalize(rootPath == null ? path : fs.path.join(rootPath!, path));

  OssClientFs({required this.service, required this.options});

  Directory get root => fs.directory(fixFsPath('.'));

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

  String getFsBucketPath(String name) => fixFsPath(name);

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
      throw OssExceptionFs(message: '$bucketDir not found', isNotFound: true);
    }
  }

  String getFsFilePath(String bucketName, String? path) =>
      fixFsPath(path == null ? bucketName : fs.path.join(bucketName, path));

  @override
  Future<void> putAsBytes(
      String bucketName, String path, Uint8List bytes) async {
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
    } on FileSystemException catch (e) {
      if (e.status == FileSystemException.statusNotFound) {
        throw OssExceptionFs(message: e.toString(), isNotFound: true);
      }
      throw OssExceptionFs(message: e.toString());
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
      await fs.file(fsFilePath).delete();
    } catch (e) {
      if (debugAliyunOssFs) {
        info('delete failed $e');
      }
    }
  }

  @override
  Future<OssListFilesResponse> list(String bucketName,
      [OssListFilesOptions? options]) async {
    var fs = await fsReady;
    var bucketPath = getFsBucketPath(bucketName);
    var parentPath = getFsFilePath(bucketName, options?.prefix);
    List<FileSystemEntity> files;
    try {
      files = await fs.directory(parentPath).list(recursive: true).toList();
    } on FileSystemException catch (_) {
      // Not found?
      files = <FileSystemEntity>[];
    }
    var paths = <String>[];
    for (var file in files) {
      if (await fs.isFile(file.path)) {
        paths.add(file.path);
      }
    }
    paths.sort();

    String _toOssPath(String path) =>
        p.url.normalize(fs.path.relative(path, from: bucketPath));

    // marker?
    // TODO too slow for now
    if (options?.marker != null) {
      int? startIndex;
      for (var i = 0; i < paths.length; i++) {
        if (options!.marker!.compareTo(_toOssPath(paths[i])) <= 0) {
          startIndex = i;
        }
      }
      if (startIndex != null) {
        paths = paths.sublist(startIndex);
      }
    }

    // limit?
    var maxResults = options?.maxResults ?? 1000;
    var isTruncated = false;
    String? nextMarker;
    if (paths.length > maxResults) {
      // set next marker
      isTruncated = true;
      nextMarker = _toOssPath(paths[maxResults]);

      paths = paths.sublist(0, maxResults);
    }

    // Convert
    var ossFiles = <OssFile>[];
    for (var path in paths) {
      var stat = await fs.file(path).stat();

      var name = _toOssPath(path);
      var size = stat.size;
      var dateModified = stat.modified;
      ossFiles
          .add(OssFileFs(name: name, size: size, lastModified: dateModified));
    }

    return OssListFilesResponseFs(
        isTruncated: isTruncated, nextMarker: nextMarker, files: ossFiles);
  }

  @override
  String toString() => 'OssClientFs(${rootPath ?? ''})';
}

// Allow setting a root path
class OssClientOptionsFs extends OssClientOptions {
  String? rootPath;

  OssClientOptionsFs()
      : super(accessKeyId: '', accessKeySecret: '', endpoint: '');
}
