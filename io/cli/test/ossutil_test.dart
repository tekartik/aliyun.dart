import 'package:tekartik_aliyun_cli/ossutil.dart';
import 'package:tekartik_common_utils/version_utils.dart';
import 'package:test/test.dart';

Future main() async {
  var ossutilSupported = false;
  try {
    await setupOssutil();
    ossutilSupported = true;
  } catch (_) {}
  group('ossutil', () {
    test('version', () async {
      var version = await getOssutilVersion();
      expect(version, greaterThanOrEqualTo(Version(1, 6, 19)));
    });
  }, skip: !ossutilSupported);
}
