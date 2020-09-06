import 'package:dev_test/package.dart';

Future main() async {
  for (var dir in [
    '../../common/tablestore',
    '../../common/tablestore_sembast',
    '../../common/tablestore_universal',
    '../../node/tablestore_node',
    '../../test/tablestore_test',
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
