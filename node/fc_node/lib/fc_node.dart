/// Aliyun Function Compute on the nodejs runtime: `aliyunFunctionComputeNode`
/// exports a `tekartik_aliyun_fc` http handler (`exports.handler`) from Dart
/// compiled with dart2js.
///
/// Node.js only. See `fc_interop.dart` for the node specific request,
/// response and context classes.
library;

export 'src/aliyun_function_compute_node.dart' show aliyunFunctionComputeNode;
