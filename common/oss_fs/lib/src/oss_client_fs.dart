import 'package:tekartik_aliyun_oss_fs/oss_fs.dart';

import 'import.dart';
import 'oss_service_fs.dart';

class OssClientFs with OssClientMixin {
  final OssServiceFs service;
  final OssClientOptions options;

  OssClientFs(
      {@required OssServiceFs service, @required OssClientOptions options})
      : service = service,
        options = options;
}
