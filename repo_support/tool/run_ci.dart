import 'package:dev_test/package.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:pub_semver/pub_semver.dart';

Future main() async {
  if (dartVersion >= Version(2, 12, 0, pre: '0')) {
    for (var dir in [
      'common/fc',
      'common/oss',
      'common/oss_fs',
      'common/oss_universal',
      'common/fc_http',
      'common/fc_universal',
      'io/cli',
      'common/tablestore',
      'common/tablestore_sembast',
      'common/tablestore_universal',
      'test/tablestore_test',
      'test/tablestore_universal_test',
      'node/fc_node',
      'node/tablestore_node',
      'node/oss_node',
    ]) {
      await packageRunCi(join('..', dir));
    }
  }
}
