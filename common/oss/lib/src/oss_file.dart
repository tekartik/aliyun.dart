abstract class OssFile {
  /// Oss file name
  String get name;

  /// Oss file size
  int get size;

  /// Modified date
  DateTime get lastModified;
}

abstract class OssListFilesResponse {
  /// Files
  List<OssFile> get files;

  /// Truncated or not
  bool get isTruncated;

  /// Next marker
  String get nextMarker;
}

/// List request
class OssListFilesOptions {
  /// Max number of items (1000 being the default).
  final int maxResults;

  /// Filter.
  final String prefix;

  /// Marker (start marker), can be modified for the next query.
  String marker;

  /// List files options.
  OssListFilesOptions({this.maxResults, this.prefix, this.marker});

  @override
  String toString() => {
        if (maxResults != null) 'maxResults': maxResults,
        if (prefix != null) 'prefix': prefix,
        if (marker != null) 'marker': marker
      }.toString();
}
