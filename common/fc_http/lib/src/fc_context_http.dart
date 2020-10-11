import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_http/http.dart' as impl;

class FcHttpContextHttp implements FcHttpContext {
  final impl.HttpRequest requestImpl;

  FcHttpContextHttp(this.requestImpl);
}
