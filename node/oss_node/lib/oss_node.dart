/// The `tekartik_aliyun_oss` API on Node.js (dart2js), over the `ali-oss`
/// npm module: `ossServiceNode` plus the whole re-exported API.
///
/// Node.js only: elsewhere `ossServiceNode` throws `UnimplementedError`.
library;

export 'package:tekartik_aliyun_oss/oss.dart';

export 'src/platform.dart' show ossServiceNode;
