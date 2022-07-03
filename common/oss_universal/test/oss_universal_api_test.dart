import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:test/test.dart';

void main() {
  void expectNode([Object? e]) {
    if (e != null) {
      expect(e, isNot(const TypeMatcher<TestFailure>()));
    }
    expect(isRunningAsJavascript, isTrue);
  }

  void expectIo([Object? e]) {
    if (e != null) {
      expect(e, isNot(const TypeMatcher<TestFailure>()));
    }
    expect(isRunningAsJavascript, isFalse);
  }

  test('api', () {
    // ignore_for_file: unnecessary_statements
    ossServiceMemory;
    newOssServiceMemory;
    debugAliyunOss;
    ossServiceUniversal;

    try {
      ossServiceFsIo;
      expectIo();
    } catch (e) {
      expectNode(e);
    }

    try {
      ossServiceNode;
      expectNode();
    } catch (e) {
      expectIo(e);
    }
  });
}
