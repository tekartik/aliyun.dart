@JS()
library;

import 'dart:js_util';

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tekartik_aliyun_oss_node/oss_node.dart';

import 'import.dart';

@JS()
@anonymous
class OssClientListBucketsParamsJs {}

@JS()
@anonymous
// {"name":"xxx-china-wj","region":"oss-cn-shanghai","creationDate":"2020-09-08T08:07:55.000Z",
// "StorageClass":"Standard","tag":{"undefined":null}}
abstract class OssClientListBucketJs {
  external String get name;

  external String get region;
}

@JS()
@anonymous
// {"buckets":[{"name":"xxxx-china-wj","region":"oss-cn-shanghai",
// "creationDate":"2020-09-08T08:07:55.000Z","StorageClass":"Standard","tag":{"undefined":null}},
// {"name":"xxxxxx-oss","region":"oss-cn-shanghai","creationDate":"2020-08-14T09:36:14.000Z",
// "StorageClass":"Standard","tag":{"undefined":null}},{"name":"bbetest1","region":"oss-cn-beijing","creationDate":"2020-08-24T16:23:01.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"bill-instance-detail","region":"oss-cn-shenzhen","creationDate":"2020-03-30T04:34:22.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"bill-resource-detail","region":"oss-cn-shenzhen","creationDate":"2020-03-30T04:34:01.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"fre-ins-int-01-oss","region":"oss-cn-shanghai","creationDate":"2020-09-12T15:32:36.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"fre-ins-ppd-01-oss","region":"oss-cn-shanghai","creationDate":"2020-09-12T15:27:34.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"fre-ins-prd-01-oss","region":"oss-cn-shanghai","creationDate":"2020-09-28T13:24:40.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"yyyy-haw-dev","region":"oss-cn-shanghai","creationDate":"2020-09-20T13:10:02.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"yyyy-haw-dev-eu","region":"oss-eu-central-1","creationDate":"2020-09-20T13:19:05.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"yyyy-haw-prod","region":"oss-cn-shanghai","creationDate":"2020-09-20T13:11:21.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"yyyy-haw-prod-eu","region":"oss-eu-central-1","creationDate":"2020-09-20T13:20:08.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"yyyy-haw-test","region":"oss-cn-shanghai","creationDate":"2020-09-20T13:12:18.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"yyyy-haw-test-eu","region":"oss-eu-central-1","creationDate":"2020-09-20T13:20:57.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"tag-actiontrail","region":"oss-cn-hangzhou","creationDate":"2019-12-16T14:25:56.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"tag-crm","region":"oss-cn-shenzhen","creationDate":"2020-03-12T07:32:13.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"tag-ftp","region":"oss-cn-shenzhen","creationDate":"2019-12-18T10:28:44.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"tag-oss-actiontrail","region":"oss-cn-hangzhou","creationDate":"2019-12-16T14:27:40.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"tagheuer-locator-slb-log","region":"oss-cn-shenzhen","creationDate":"2020-03-15T02:19:11.000Z","StorageClass":"Standard","tag":{"undefined":null}},{"name":"wj-gc","region":"oss-cn-shenzhen","creationDate":"2020-03-26T09:03:21.000Z","StorageClass":"IA","tag":{"undefined":null}},{"name":"zen-ecom","region":"oss-cn-shanghai","creationDate":"2020-10-29T14:57:11.000Z","StorageClass":"Standard","tag":{"undefined":null}}],"owner":{"id":"1932171136714243","displayName":"1932171136714243"},"isTruncated":false,"nextMarker":null,"res":{"status":200,"statusCode":200,"statusMessage":"OK","headers":{"server":"AliyunOSS","date":"Fri, 20 Nov 2020 14:06:35 GMT","content-type":"application/xml","content-length":"9109","connection":"keep-alive","x-oss-request-id":"5FB7CD6BA4DF8D3033EAE71D","x-oss-server-time":"5"},"size":9109,"aborted":false,"rt":856,"keepAliveSocket":false,"data":[...],"requestUrls":["http://oss-cn-shanghai.aliyuncs.com/?constructor=&%24isOssClientListBucketsParamsJs=&get%24hashCode=&get%24runtimeType=&toString%240=&%24isOS=1&%24isOssClientListBucketJs=1&%24isOssClientListBucketsResponseJs=1&%24isOssClientGetBucketInfoResponseJs=1&%24isOssClientJs=1&get%24length=&write%241=&clear%240=&on%242=&get%24close=&close%240=&get%24start=&get%24end=&get%24message=&connect%241=&setEncoding%241=&platform%240=&get%24name=&get%24env=&get%24sourceUrl=&get%24buckets=&get%24bucket=&listBuckets%241=&getBucketInfo%241=&super%24JavaScriptObject%24toString=&%24isJavaScriptObject=&%24eq=&noSuchMethod%241=&super%24Interceptor%24noSuchMethod=&%24isInterceptor=&%24isObject=&toString="],"timing":null,"remoteAddress":"106.14.228.194","remotePort":80,"socketHandledRequests":1,"socketHandledResponses":1}}
abstract class OssClientListBucketsResponseJs {
  external List get buckets;
}

/*

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

  /// Marker (start marker).
  final String marker;

  /// List files options.
  OssListFilesOptions({this.maxResults, this.prefix, this.marker});

  @override
  String toString() => {
        if (maxResults != null) 'maxResults': maxResults,
        if (prefix != null) 'prefix': prefix,
        if (marker != null) 'marker': marker
      }.toString();
}
 */
@JS()
@anonymous
class OssClientListFilesParamsJs {
  // We cannot add 'max-keys' here
  @protected
  external factory OssClientListFilesParamsJs({String? prefix, String? marker});
}

OssClientListFilesParamsJs newOssClientListFilesParamsJs(
    {int? maxKeys, String? prefix, String? marker}) {
  var param = OssClientListFilesParamsJs(prefix: prefix, marker: marker);
  if (maxKeys != null) {
    setProperty(param, 'max-keys', maxKeys);
  }
  return param;
}

@JS()
@anonymous
// {"name":"xxxxxx","url":"xxxx","lastModified":"2020-11-19T09:07:54.000Z","etag":"\"B968C3C3F559CA327B681B740F010C0C\"","type":"Normal",
// "size":120,"storageClass":"Standard","owner":{"id":"1932171136714243","displayName":"1932171136714243"}
abstract class OssFileJs {
  external String get name;

  external String get lastModified;

  external int get size;
}

@JS()
@anonymous
// {"objects":[...],"nextMarker":"test/list_files/yes/file1.txt","isTruncated":true}
abstract class OssClientListFilesResponseJs {
  external List get objects;

  external String get nextMarker;

  external bool get isTruncated;
}

List<OssFileJs> ossClientListFilesObjects(
        OssClientListFilesResponseJs response) =>
    response.objects.cast<OssFileJs>();
/*
@JS()
@anonymous
class OssClientGetBucketInfoParamsJs {
  external String get name;
  external factory OssClientGetBucketInfoParamsJs({String name});
}*/

@JS()
@anonymous
// {Comment: ,
// CreationDate: 2020-09-08T08:07:55.000Z,
// DataRedundancyType: LRS,
// ExtranetEndpoint: oss-cn-shanghai.aliyuncs.com,
// IntranetEndpoint: oss-cn-shanghai-internal.aliyuncs.com,
// Location: oss-cn-shanghai,
// Name: actiontrail-xxxx-china-wj,
// StorageClass: Standard,
// Owner: {DisplayName: 1932171136714243, ID: 1932171136714243},
// AccessControlList: {Grant: private}, ServerSideEncryptionRule: {SSEAlgorithm: AES256},
// BucketPolicy: {LogBucket: , LogPrefix: }}, res: {status: 200, statusCode: 200, statusMessage: OK, headers: {server: AliyunOSS, date: Fri, 20 Nov 2020 13:59:44 GMT, content-type: application/xml, content-length: 884, connection: keep-alive, x-oss-request-id: 5FB7CBD0A9255735389513DA, x-oss-server-time: 4}, size: 884, aborted: false, rt: 956, keepAliveSocket: false, data: [...], requestUrls: [http://actiontrail-xxxx-china-wj.oss-cn-shanghai.aliyuncs.com/?bucketInfo=], timing: null, remoteAddress: 106.14.228.40, remotePort: 80, socketHandledRequests: 1, socketHandledResponses: 1}}
// null
abstract class OssClientBucketInfoJs {
  // ignore: non_constant_identifier_names
  external String get Name;

  // ignore: non_constant_identifier_names
  external String get Location;
}

@JS()
@anonymous
// /oss_node <resp>: {"name":"test/file.txt","url":"http://yyyy-haw-test.oss-cn-shanghai.aliyuncs.com/test/file.txt","res":{"status":200,"statusCode":200,"statusMessage":"OK","headers":{"server":"AliyunOSS","date":"Fri, 20 Nov 2020 17:46:36 GMT","content-length":"0","connection":"keep-alive","x-oss-request-id":"5FB800FC3A90A23738741C87","etag":"\"F0F18C2C66AE1DD512BDCD4366F76DA3\"","x-oss-hash-crc64ecma":"5213097489099810948","content-md5":"8PGMLGauHdUSvc1DZvdtow==","x-oss-server-time":"14"},"size":0,"aborted":false,"rt":424,"keepAliveSocket":true,"data":[],"requestUrls":["http://yyyy-haw-test.oss-cn-shanghai.aliyuncs.com/test/file.txt"],"timing":null,"remoteAddress":"106.14.228.106","remotePort":80,"socketHandledRequests":2,"socketHandledResponses":2}}
abstract class OssClientPutResponseJs {
  external String get name;
}

@JS()
@anonymous
// /oss_node <resp>: {"res":{"status":200,"statusCode":200,"statusMessage":"OK","headers":{"server":"AliyunOSS","date":"Fri, 20 Nov 2020 17:52:26 GMT","content-type":"text/plain","content-length":"9","connection":"keep-alive","x-oss-request-id":"5FB8025A8FA8AA32364470A8","accept-ranges":"bytes","etag":"\"F0F18C2C66AE1DD512BDCD4366F76DA3\"","last-modified":"Fri, 20 Nov 2020 17:52:25 GMT","x-oss-object-type":"Normal","x-oss-hash-crc64ecma":"5213097489099810948","x-oss-storage-class":"Standard","content-md5":"8PGMLGauHdUSvc1DZvdtow==","x-oss-server-time":"3"},"size":9,"aborted":false,"rt":395,"keepAliveSocket":true,"data":[72,101,108,108,111,32,79,83,83],"requestUrls":["http://yyyy-haw-test.oss-cn-shanghai.aliyuncs.com/test/file.txt"],"timing":null,"remoteAddress":"106.14.228.106","remotePort":80,"socketHandledRequests":3,"socketHandledResponses":3},"content":[72,101,108,108,111,32,79,83,83]}
abstract class OssClientGetResponseJs {
  external OssClientGetResultJs get res;
}

@JS()
@anonymous
// /oss_node <resp>: {"res":{"status":204,"statusCode":204,"statusMessage":"No Content","headers":{"server":"AliyunOSS","date":"Fri, 20 Nov 2020 18:06:56 GMT","content-length":"0","connection":"keep-alive","x-oss-request-id":"5FB805C08D80F837350D96C8","x-oss-server-time":"5"},"size":0,"aborted":false,"rt":368,"keepAliveSocket":true,"data":[],"requestUrls":["http://yyyy-haw-test.oss-cn-shanghai.aliyuncs.com/test/file.txt"],"timing":null,"remoteAddress":"106.14.228.106","remotePort":80,"socketHandledRequests":4,"socketHandledResponses":4}}
abstract class OssClientDeleteResponseJs {}

@JS()
@anonymous
// /oss_node <resp>: {"res":{"status":200,"statusCode":200,"statusMessage":"OK","headers":{"server":"AliyunOSS",
// "date":"Fri, 20 Nov 2020 17:52:26 GMT","content-type":"text/plain","content-length":"9","connection":"keep-alive",
// "x-oss-request-id":"5FB8025A8FA8AA32364470A8","accept-ranges":"bytes","etag":"\"F0F18C2C66AE1DD512BDCD4366F76DA3\"",
// "last-modified":"Fri, 20 Nov 2020 17:52:25 GMT","x-oss-object-type":"Normal","x-oss-hash-crc64ecma":"5213097489099810948"
// ,"x-oss-storage-class":"Standard","content-md5":"8PGMLGauHdUSvc1DZvdtow==","x-oss-server-time":"3"},"size":9,
// "aborted":false,"rt":395,"keepAliveSocket":true,"data":[72,101,108,108,111,32,79,83,83],
// "requestUrls":["http://yyyy-haw-test.oss-cn-shanghai.aliyuncs.com/test/file.txt"],"timing":null,"remoteAddress":"106.14.228.106","remotePort":80,"socketHandledRequests":3,"socketHandledResponses":3},"content":[72,101,108,108,111,32,79,83,83]}
abstract class OssClientGetResultJs {
  external String get name;

  external Buffer get data;
}

@JS()
@anonymous
// {bucket: {Comment: , CreationDate: 2020-09-08T08:07:55.000Z, DataRedundancyType: LRS, ExtranetEndpoint: oss-cn-shanghai.aliyuncs.com, IntranetEndpoint: oss-cn-shanghai-internal.aliyuncs.com, Location: oss-cn-shanghai, Name: actiontrail-xxxx-china-wj, StorageClass: Standard, Owner: {DisplayName: 1932171136714243, ID: 1932171136714243}, AccessControlList: {Grant: private}, ServerSideEncryptionRule: {SSEAlgorithm: AES256}, BucketPolicy: {LogBucket: , LogPrefix: }}, res: {status: 200, statusCode: 200, statusMessage: OK, headers:
// {server: AliyunOSS, date: Fri, 20 Nov 2020 13:59:44 GMT, content-type: application/xml, content-length: 884,
// connection: keep-alive, x-oss-request-id: 5FB7CBD0A9255735389513DA, x-oss-server-time: 4},
// size: 884, aborted: false, rt: 956, keepAliveSocket: false, data:[...], requestUrls: [http://actiontrail-xxxx-china-wj.oss-cn-shanghai.aliyuncs.com/?bucketInfo=], timing: null, remoteAddress: 106.14.228.40, remotePort: 80, socketHandledRequests: 1, socketHandledResponses: 1}}
// null
abstract class OssClientGetBucketInfoResponseJs {
  external OssClientBucketInfoJs get bucket;
}

/// A structure for options provided to OSS.
@JS()
@anonymous
class OssClientOptionsJs {
  external String get accessKeyId;

  external String get accessKeySecret;

  external String get endpoint;

  external factory OssClientOptionsJs(
      {String? accessKeyId, String? accessKeySecret, String? endpoint});
}

/// Wrap a native error
OssExceptionNode wrapNativeError(dynamic err) {
  if (err is OssExceptionNode) {
    return err;
  }
  Map? errMap;
  String? message;
  // Try json
  try {
    errMap = jsObjectAsMap(err);
  } catch (_) {
    message = err.toString();
  }

  if (debugAliyunOss) {
    if (errMap != null) {
      print('OSS!: errMap: ${jsonEncode(errMap)}');
    } else {
      print('OSS!: err: ${nativeDataToDebugString(err)}');
    }
  }
  return OssExceptionNode(message: message, map: errMap);
}

@JS()
@anonymous
class OssClientJs {
  external Promise listBuckets(OssClientListBucketsParamsJs params);

  external Promise getBucketInfo(String name);

  external void useBucket(String name);

  external Promise put(String path, Buffer buffer);

  external Promise get(String path);

  external Promise delete(String path);

  external Promise list(OssClientListFilesParamsJs? params);
}

Future<OssClientListFilesResponseJs> ossClientJsListFiles(
    OssClientJs client, OssClientListFilesParamsJs? params) async {
  return (await promiseToFuture<Object>(client.list(params)))
      as OssClientListFilesResponseJs;
}

/// ```javascript
/// const OSS = require('ali-oss');
///
/// const client = new OSS({
///   // The endpoint of the China (Hangzhou) region is used in this example. Specify the actual endpoint.
///   region: '<Your region>',
///   // Security risks may arise if you use the AccessKey pair of an Alibaba Cloud account to log on to OSS because the account has permissions on all API operations. We recommend that you use your RAM user's credentials to call API operations or perform routine operations and maintenance. To create a RAM user, log on to the RAM console.
///   accessKeyId: '<Your AccessKeyId>',
///   accessKeySecret: '<Your AccessKeySecret>'
/// });
/// ```
final ossServiceJs = require('ali-oss') as Object;

/// Convert a native object to a debug string
String? nativeDataToDebugString(dynamic data) {
  try {
    // Handle common types
    if (data is String) {
      return data;
    }
    String? text;
    try {
      text = jsonEncode(jsObjectAsMap(data));
    } catch (_) {
      try {
        text = jsObjectToDebugString(data);
      } catch (_) {
        text = data.toString();
      }
    }
    return text;
  } catch (e) {
    try {
      return '<error: $e> ${data.toString()}';
    } catch (_) {
      return '<error: $e>';
    }
  }
}

/// New client
OssClientJs ossNewClient(OssClientOptionsJs options) {
  var nativeClient = callConstructor(ossServiceJs, [options]) as OssClientJs;
  return nativeClient;
}
