import 'package:tekartik_aliyun_oss_universal/oss_universal.dart';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:test/test.dart';

void main() {
  void _expectNode([Object? e]) {
    if (e != null) {
      expect(e, isNot(const TypeMatcher<TestFailure>()));
    }
    expect(isRunningAsJavascript, isTrue);
  }

  void _expectIo([Object? e]) {
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
      _expectIo();
    } catch (e) {
      _expectNode(e);
    }

    try {
      ossServiceNode;
      _expectNode();
    } catch (e) {
      _expectIo(e);
    }
  });
}
