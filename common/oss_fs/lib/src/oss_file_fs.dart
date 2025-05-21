import '../oss_fs.dart';

class OssFileFs implements OssFile {
  @override
  final String name;

  @override
  final int size;

  @override
  final DateTime lastModified;

  OssFileFs({
    required this.name,
    required this.size,
    required this.lastModified,
  });

  @override
  String toString() =>
      {'name': name, 'size': size, 'lastModified': lastModified}.toString();
}

class OssListFilesResponseFs implements OssListFilesResponse {
  OssListFilesResponseFs({
    required this.isTruncated,
    required this.nextMarker,
    required this.files,
  });

  @override
  final List<OssFile> files;

  @override
  final bool isTruncated;

  @override
  final String? nextMarker;
}
