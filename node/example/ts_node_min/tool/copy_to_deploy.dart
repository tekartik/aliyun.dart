import 'dart:io';

Future main() async {
  // var shell = Shell();
  // await shell.run('pub run build_runner build --output=build/');
  await File('build/bin/main.dart.js').copy('deploy/index.js');
  print('copied to ${await File('deploy/index.js').stat()}');
}

Future copyToDeploy({String directory = 'bin'}) async {
  var file =
      await File('build/$directory/main.dart.js').copy('deploy/index.js');
  print('copied to ${file} ${await file.stat()}');
}
