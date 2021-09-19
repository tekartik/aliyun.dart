import 'package:cv/cv.dart';

abstract class OssBucket {
  /// Oss bucket name
  String get name;

  /// Oss bucket location
  String get location;
}

mixin OssBucketMixin implements OssBucket {
  Model toDebugMap() {
    return asModel({'name': name})..setValue('location', location);
  }

  @override
  String toString() => toDebugMap().toString();
}
