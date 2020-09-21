import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_http/http.dart' as impl;

class FcHttpResponseHttp implements FcHttpResponse {
  final impl.HttpRequest requestImpl;

  FcHttpResponseHttp(this.requestImpl);
  @override
  Future sendString(String body) async {
    requestImpl.response.write(body);
    await requestImpl.response.close();
    //await requestImpl.response.flush();
  }

  @override
  void setHeader(String name, String value) {
    requestImpl.response.headers.set(name, value);
  }

  @override
  void setStatusCode(int statusCode) {
    requestImpl.response.statusCode = statusCode;
  }
}
