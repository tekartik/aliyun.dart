// ignore_for_file: deprecated_member_use
@TestOn('node')
library;

import 'dart:async';
import 'dart:js_util' as jsu;
import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart' as node;
import 'package:tekartik_aliyun_oss_node/oss_node.dart';
import 'package:tekartik_aliyun_oss_node/src/oss_client_node.dart';
import 'package:tekartik_aliyun_oss_node/src/oss_interop.dart';
import 'package:test/test.dart';

/// An ali-oss request error (`lib/client.js` requestError): an `Error` whose
/// name is `<Code>Error`, with the http `status` and the OSS `code`.
Object ossError(String code, int status, String message) {
  var error = jsu.callConstructor<Object>(
    jsu.getProperty<Object>(jsu.globalThis, 'Error'),
    [message],
  );
  jsu.setProperty(error, 'name', '${code}Error');
  jsu.setProperty(error, 'status', status);
  jsu.setProperty(error, 'code', code);
  return error;
}

Object rejected(Object error) => jsu.callMethod<Object>(
  jsu.getProperty<Object>(jsu.globalThis, 'Promise'),
  'reject',
  [error],
);

/// A native client whose calls fail with the errors of [errorFor].
OssClientNode newFailingClient(List<String> calls, Object Function() error) {
  var native = jsu.newObject<Object>();
  jsu.setProperty(native, 'useBucket', allowInterop((Object? name) {}));
  for (var method in ['getBucketInfo', 'put', 'get', 'list']) {
    jsu.setProperty(
      native,
      method,
      allowInterop(([Object? arg1, Object? arg2]) {
        calls.add(method);
        return rejected(error());
      }),
    );
  }
  return OssClientNode(native as OssClientJs);
}

/// An OSS NoSuchBucket error answer.
const noSuchBucketXml =
    '<?xml version="1.0" encoding="UTF-8"?><Error>'
    '<Code>NoSuchBucket</Code>'
    '<Message>The specified bucket does not exist.</Message>'
    '<RequestId>0</RequestId></Error>';

void main() {
  group('oss_client_node errors', () {
    test('getBucket missing bucket', () async {
      // Was retried 3 times then OssExceptionNode(timeout), isNotFound false.
      var calls = <String>[];
      var client = newFailingClient(
        calls,
        () => ossError(
          'NoSuchBucket',
          404,
          'The specified bucket does not exist.',
        ),
      );
      try {
        await client.getBucket('missing');
        fail('should fail');
      } on OssException catch (e) {
        expect(e.isNotFound, isTrue);
        expect(e.retryable, isFalse);
        expect(e.toString(), contains('The specified bucket does not exist.'));
      }
      expect(calls, ['getBucketInfo']);
    });
    test('putAsBytes access denied', () async {
      var calls = <String>[];
      var client = newFailingClient(
        calls,
        () => ossError('AccessDenied', 403, 'You have no right to access.'),
      );
      try {
        await client.putAsBytes('bucket', 'file.txt', Uint8List.fromList([1]));
        fail('should fail');
      } on OssException catch (e) {
        expect(e.isNotFound, isFalse);
        expect(e.retryable, isFalse);
        expect(e.toString(), contains('You have no right to access.'));
      }
      expect(calls, ['put']);
    });
    test('list missing bucket', () async {
      var calls = <String>[];
      var client = newFailingClient(
        calls,
        () => ossError(
          'NoSuchBucket',
          404,
          'The specified bucket does not exist.',
        ),
      );
      try {
        await client.list('missing');
        fail('should fail');
      } on OssException catch (e) {
        expect(e.isNotFound, isTrue);
      }
      expect(calls, ['list']);
    });
    test('getAsBytes missing file', () async {
      var calls = <String>[];
      var client = newFailingClient(
        calls,
        () => ossError('NoSuchKey', 404, 'The specified key does not exist.'),
      );
      try {
        await client.getAsBytes('bucket', 'missing.txt');
        fail('should fail');
      } on OssException catch (e) {
        expect(e.isNotFound, isTrue);
        expect(e.retryable, isFalse);
      }
      expect(calls, ['get']);
    });
    test('server error retried, last error kept', () async {
      var calls = <String>[];
      var client = newFailingClient(
        calls,
        () =>
            ossError('InternalError', 500, 'We encountered an internal error.'),
      );
      try {
        await client.getAsBytes('bucket', 'file.txt');
        fail('should fail');
      } on OssException catch (e) {
        expect(e.isNotFound, isFalse);
        expect(e.retryable, isTrue);
        expect(e.toString(), contains('We encountered an internal error.'));
      }
      expect(calls, ['get', 'get', 'get']);
    });
  }, timeout: const Timeout(Duration(seconds: 20)));

  group('ali-oss client', () {
    test('404 answer of a local server', () async {
      // An OSS like server answering NoSuchBucket to every request.
      var requests = <String>[];
      var server = jsu.callMethod<Object>(
        node.require('http') as Object,
        'createServer',
        [
          allowInterop((Object request, Object response) {
            requests.add('${jsu.getProperty<Object?>(request, 'url')}');
            jsu.callMethod<Object?>(response, 'writeHead', [
              404,
              jsu.jsify({'content-type': 'application/xml'}),
            ]);
            jsu.callMethod<Object?>(response, 'end', [noSuchBucketXml]);
          }),
        ],
      );
      var listening = Completer<void>();
      jsu.callMethod<Object?>(server, 'listen', [
        0,
        '127.0.0.1',
        allowInterop(listening.complete),
      ]);
      await listening.future;
      addTearDown(() => jsu.callMethod<Object?>(server, 'close', []));
      var port = jsu.getProperty<Object>(
        jsu.callMethod<Object>(server, 'address', []),
        'port',
      );
      var client = ossServiceNode.client(
        options: OssClientOptions(
          endpoint: 'http://127.0.0.1:$port',
          accessKeyId: 'id',
          accessKeySecret: 'secret',
        ),
      );
      for (var action in <Future<Object?> Function()>[
        () => client.getBucket('missing'),
        () => client.getAsBytes('missing', 'file.txt'),
        () => client.list('missing'),
      ]) {
        requests.clear();
        try {
          await action();
          fail('should fail');
        } on OssException catch (e) {
          expect(e.isNotFound, isTrue);
          expect(e.retryable, isFalse);
          expect(
            e.toString(),
            contains('The specified bucket does not exist.'),
          );
        }
        expect(requests, hasLength(1));
      }
    });
  }, timeout: const Timeout(Duration(seconds: 20)));
}
