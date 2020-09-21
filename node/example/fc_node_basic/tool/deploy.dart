import 'package:http/http.dart';
import 'package:process_run/shell_run.dart';
import 'package:process_run/utils/process_result_extension.dart';

Future<void> main() async {
  await deploy();
}

Future<void> deploy() async {
  var shell = Shell(workingDirectory: 'deploy');
  var lines = (await shell.run('fun deploy')).outLines;
  String foundUrl;
  // Extract from 'url: https://xxxxx.eu-central-1.fc.aliyuncs.com/xxxxxx/'
  for (var line in lines) {
    var text = line.trim();
    var parts = text.split(' ');
    if (parts[0] == 'url:' && parts.length > 1) {
      foundUrl = parts[1];
    }
  }
  if (foundUrl != null) {
    print('url: $foundUrl');
    var response = await get(foundUrl, headers: {'x-in': 'in-value'});
    print('status code: ${response.statusCode}');
    print('headers: ${response.headers}');
    print(response.body);
  }
}

// {
//   "version": 3,
//   "tag": "v1",
//   "method": "GET",
//   "body": "",
//   "path": "/",
//   "url": "/xxxxxxxxxxxxxxxxxx/tekartik_fc_node/fc_node_basic/",
//   "headers": {
//     "content-length": "0",
//     "host": "xxxxxxxxxxxxxx218.eu-xxxxxx-1.fc.aliyuncs.com",
//     "user-agent": "Dart/2.9 (dart:io)",
//     "x-forwarded-proto": "https",
//     "x-in": "in-value"
//   },
//   "env": {
//     "LD_LIBRARY_PATH": "/code/.fun/root/usr/local/lib:/code/.fun/root/usr/lib:/code/.fun/root/usr/lib/x86_64-linux-gnu:/code/.fun/root/usr/lib64:/code/.fun/root/lib:/code/.fun/root/lib/x86_64-linux-gnu:/code/.fun/root/python/lib/python2.7/site-packages:/code/.fun/root/python/lib/python3.6/site-packages:/code:/code/lib:/usr/local/lib",
//     "YARN_VERSION": "1.22.0",
//     "HOSTNAME": "xxxxxxxxxxxxxxx",
//     "NODE_PATH": "/code/node_modules:/usr/local/lib/node_modules",
//     "FC_FUNC_CODE_PATH": "/code/",
//     "PWD": "/code",
//     "HOME": "/tmp",
//     "NODE_VERSION": "12.16.1",
//     "TERM": "xterm",
//     "SHLVL": "1",
//     "PYTHONUSERBASE": "/code/.fun/python",
//     "PATH": "/code/.fun/root/usr/local/bin:/code/.fun/root/usr/local/sbin:/code/.fun/root/usr/bin:/code/.fun/root/usr/sbin:/code/.fun/root/sbin:/code/.fun/root/bin:/code:/code/node_modules/.bin:/code/.fun/python/bin:/code/.fun/node_modules/.bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin",
//     "_": "/usr/local/bin/node"
//   }
// }
