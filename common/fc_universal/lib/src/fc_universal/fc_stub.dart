import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_aliyun_fc_universal/src/fc_universal/fc_common.dart';

/// Can be called only once
@deprecated
void exportHttpHandler(FcHttpHandler handler, {String name = 'handler'}) =>
    throw UnsupportedError('exportHttpHandler');

AliyunFunctionComputeUniversal get aliyunFunctionCompute =>
    throw UnsupportedError('aliyunFunctionCompute');
