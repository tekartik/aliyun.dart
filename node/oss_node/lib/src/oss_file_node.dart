import 'package:tekartik_aliyun_oss/oss.dart';

import 'oss_interop.dart' as interop;

interop.OssClientListFilesParamsJs? unwrapListFilesOptions(
    OssListFilesOptions? options) {
  if (options == null) {
    return null;
  }
  return interop.newOssClientListFilesParamsJs(
      maxKeys: options.maxResults,
      marker: options.marker,
      prefix: options.prefix);
}

class OssFileNode implements OssFile {
  final interop.OssFileJs nativeInstance;

  OssFileNode(this.nativeInstance);

  @override
  DateTime get lastModified => DateTime.tryParse(nativeInstance.lastModified)!;

  @override
  String get name => nativeInstance.name;

  @override
  int get size => nativeInstance.size;
}

class OssListFilesResponseNode implements OssListFilesResponse {
  final interop.OssClientListFilesResponseJs nativeInstance;

  OssListFilesResponseNode(this.nativeInstance);

  @override
  List<OssFile> get files => interop
      .ossClientListFilesObjects(nativeInstance)
      .map((e) => OssFileNode(e))
      .toList();

  @override
  bool get isTruncated => nativeInstance.isTruncated;

  @override
  String get nextMarker => nativeInstance.nextMarker;
}
