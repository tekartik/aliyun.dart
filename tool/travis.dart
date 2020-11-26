import 'package:dev_test/package.dart';

Future main() async {
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
    print('package: $dir');
    await ioPackageRunCi(dir);
    /*
    var shell = Shell();


    shell = shell.pushd(dir);
    await shell.run('''

    pub get
    dart tool/travis.dart

''');
    shell = shell.popd();

     */
  }
}
