import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:process_run/utils/process_result_extension.dart';

Future<void> main() async {
  await deploy();
}

Future<void> deploy() async {
  var shell = Shell(workingDirectory: 'deploy');
  var lines = (await shell.run('fun deploy')).outLines;
  String? foundUrl;
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
    var response =
        await get(Uri.parse(foundUrl), headers: {'x-in': 'in-value'});
    print('status code: ${response.statusCode}');
    print('headers: ${response.headers}');
    print(response.body);

    var asyncUrl = url.join(foundUrl, 'async');
    print('url: $asyncUrl');
    response = await get(Uri.parse(asyncUrl), headers: {'x-in': 'in-value'});
    print('status code: ${response.statusCode}');
    print('headers: ${response.headers}');
    print(response.body);

    var bodyStringUrl = url.join(foundUrl, 'bodyString');
    print('url: $bodyStringUrl');
    response = await post(Uri.parse(bodyStringUrl), body: 'some text');
    print('status code: ${response.statusCode}');
    print('headers: ${response.headers}');
    print(response.body);

    var bodyBytesUrl = url.join(foundUrl, 'bodyBytes');
    print('url: $bodyBytesUrl');
    response = await post(Uri.parse(bodyBytesUrl),
        body: Uint8List.fromList([1, 2, 3]));
    print('status code: ${response.statusCode}');
    print('headers: ${response.headers}');
    print(response.bodyBytes);
    // status code: 200
    // headers: {content-disposition: attachment, date: Mon, 12 Oct 2020 13:12:33 GMT, x-fc-invocation-duration: 45, x-fc-invocation-service-version: LATEST, content-length: 3, x-fc-request-id: ea2e4004-83f9-4723-b9d8-6cbc05fbf7e3, access-control-expose-headers: Date,x-fc-request-id,x-fc-error-type,x-fc-code-checksum,x-fc-invocation-duration,x-fc-max-memory-usage,x-fc-log-result,x-fc-invocation-code-version, x-fc-code-checksum: 2321752769879710394, x-fc-max-memory-usage: 17.23, content-type: application/octet-stream}
    // [1, 2, 3]
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
