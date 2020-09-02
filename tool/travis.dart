import 'package:dev_test/package.dart';

Future main() async {
  for (var dir in [
    'common/fc',
    'common/fc_universal',
    'common/tablestore',
    'common/tablestore_sembast',
    //'common/tablestore_universal',
    'node/fc_node',
    'test/tablestore_test',
  ]) {
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
