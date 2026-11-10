// ignore_for_file: deprecated_member_use
@TestOn('node')
library;

import 'dart:js_util' as jsu;

import 'package:node_interop/node_interop.dart' as node;
import 'package:tekartik_aliyun_fc_node/fc_interop.dart';
import 'package:test/test.dart';

/// A Function Compute like request: a readable stream holding [body].
HttpReqJs newRequest(String body) {
  var buffer = jsu.callMethod<Object>(
    jsu.getProperty<Object>(jsu.globalThis, 'Buffer'),
    'from',
    [body],
  );
  var readable = jsu.callMethod<Object>(
    jsu.getProperty<Object>(node.require('stream') as Object, 'Readable'),
    'from',
    [
      [buffer],
    ],
  );
  jsu.setProperty(readable, 'path', '/handler/test');
  jsu.setProperty(readable, 'url', '/handler/test?a=1');
  jsu.setProperty(readable, 'method', 'POST');
  jsu.setProperty(
    readable,
    'headers',
    jsu.jsify({'Content-Type': 'text/plain'}),
  );
  return readable as HttpReqJs;
}

void main() {
  group('FcHttpRequestNode', () {
    test('getBodyString', () async {
      var request = FcHttpRequestNode(newRequest('héllo'));
      expect(await request.getBodyString(), 'héllo');
    });
    test('getBodyBytes', () async {
      var request = FcHttpRequestNode(newRequest('hello'));
      expect(await request.getBodyBytes(), [104, 101, 108, 108, 111]);
    });
    test('getBodyString then getBodyBytes', () async {
      // The body was cached as a String: TypeError on the bytes.
      var request = FcHttpRequestNode(newRequest('hello'));
      expect(await request.getBodyString(), 'hello');
      expect(await request.getBodyBytes(), [104, 101, 108, 108, 111]);
    });
    test('getBodyBytes then getBodyString', () async {
      // The body was cached as bytes: '[104, 101, ...]' as the string.
      var request = FcHttpRequestNode(newRequest('hello'));
      expect(await request.getBodyBytes(), [104, 101, 108, 108, 111]);
      expect(await request.getBodyString(), 'hello');
    });
    test('both at once', () async {
      var request = FcHttpRequestNode(newRequest('hello'));
      var results = await Future.wait<Object>([
        request.getBodyString(),
        request.getBodyBytes(),
      ]);
      expect(results, [
        'hello',
        [104, 101, 108, 108, 111],
      ]);
    });
    test('headers, method, path', () {
      var request = FcHttpRequestNode(newRequest(''));
      expect(request.headers['content-type'], 'text/plain');
      expect(request.headers['Content-Type'], 'text/plain');
      expect(request.method, 'POST');
      expect(request.path, '/handler/test');
      expect(request.url, '/handler/test?a=1');
    });
  }, timeout: const Timeout(Duration(seconds: 10)));
}
