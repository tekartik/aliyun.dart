import 'package:tekartik_aliyun_fc_universal/fc_universal.dart';
import 'package:tekartik_aliyun_fc_universal/src/fc_universal_common.dart';
import 'package:tekartik_http_io/http_server_io.dart';

@deprecated
void exportHttpHandler(FcHttpHandler handler, {String name = 'handler'}) =>
    throw UnsupportedError('exportHttpHandler');

class AliyunFunctionComputeHttpUniversalIo
    extends AliyunFunctionComputeHttpUniversal {
  AliyunFunctionComputeHttpUniversalIo() : super(httpServerFactoryIo);
}

final AliyunFunctionComputeUniversal aliyunFunctionComputeUniversal =
    AliyunFunctionComputeHttpUniversalIo();
