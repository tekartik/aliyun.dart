// ignore_for_file: deprecated_member_use
@TestOn('node')
library;

import 'dart:async';
import 'dart:js_util' as jsu;

import 'package:js/js.dart';
import 'package:node_interop/node_interop.dart' as node;
import 'package:tekartik_aliyun_fc/fc_api.dart';
import 'package:tekartik_aliyun_fc_node/fc_node.dart';
import 'package:test/test.dart';

/// A Function Compute like response recording the calls.
class FcResponseRecorder {
  final calls = <String>[];
  late final Object js = () {
    var js = jsu.newObject<Object>();
    jsu.setProperty(
      js,
      'setStatusCode',
      allowInterop((Object? code) => calls.add('status $code')),
    );
    jsu.setProperty(
      js,
      'setHeader',
      allowInterop((Object? key, Object? value) => calls.add('$key: $value')),
    );
    jsu.setProperty(
      js,
      'send',
      allowInterop((Object? body) => calls.add('send $body')),
    );
    return js;
  }();
}

/// Calls the exported handler as the Function Compute runtime does and
/// returns the uncaught errors.
Future<List<Object>> callExportedHandler(FcResponseRecorder response) async {
  var handler = jsu.getProperty<Object>(node.exports as Object, 'handler');
  var request = jsu.newObject<Object>();
  jsu.setProperty(request, 'headers', jsu.newObject<Object>());
  var errors = <Object>[];
  await runZonedGuarded(
    () async {
      jsu.callMethod<Object?>(handler, 'call', [
        null,
        request,
        response.js,
        jsu.newObject<Object>(),
      ]);
      // Let the handler run.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    },
    (e, st) {
      errors.add(e);
    },
  );
  return errors;
}

void main() {
  group('exportHttpHandler', () {
    test('send', () async {
      aliyunFunctionComputeNode.exportHttpHandler((
        FcHttpRequest request,
        FcHttpResponse response,
        FcHttpContext context,
      ) async {
        response.setStatusCode(201);
        await response.sendString('created');
      });
      var response = FcResponseRecorder();
      expect(await callExportedHandler(response), isEmpty);
      expect(response.calls, ['status 201', 'send created']);
    });
    test('handler error answers 500', () async {
      // The error was uncaught and no response was sent.
      aliyunFunctionComputeNode.exportHttpHandler((
        FcHttpRequest request,
        FcHttpResponse response,
        FcHttpContext context,
      ) async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        throw StateError('handler failure');
      });
      var response = FcResponseRecorder();
      expect(await callExportedHandler(response), isEmpty);
      expect(response.calls, ['status 500', 'send error']);
    });
    test('sync handler error answers 500', () async {
      aliyunFunctionComputeNode.exportHttpHandler((
        FcHttpRequest request,
        FcHttpResponse response,
        FcHttpContext context,
      ) {
        throw StateError('handler failure');
      });
      var response = FcResponseRecorder();
      expect(await callExportedHandler(response), isEmpty);
      expect(response.calls, ['status 500', 'send error']);
    });
  }, timeout: const Timeout(Duration(seconds: 10)));
}
