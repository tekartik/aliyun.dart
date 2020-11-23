import '../oss_fs.dart';

class OssFileFs implements OssFile {
  @override
  final String name;

  @override
  final int size;

  @override
  final DateTime lastModified;

  OssFileFs({this.name, this.size, this.lastModified});

  @override
  String toString() =>
      {'name': name, 'size': size, 'lastModified': lastModified}.toString();
}

class OssListFilesResponseFs implements OssListFilesResponse {
  OssListFilesResponseFs({this.isTruncated, this.nextMarker, this.files});

  @override
  final List<OssFile> files;

  @override
  final bool isTruncated;

  @override
  final String nextMarker;
}
