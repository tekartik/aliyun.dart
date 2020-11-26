import 'package:tekartik_common_utils/model/model.dart';

abstract class OssBucket {
  /// Oss bucket name
  String get name;

  /// Oss bucket location
  String get location;
}

mixin OssBucketMixin implements OssBucket {
  Model toDebugMap() {
    return Model({'name': name})..setValue('location', location);
  }

  @override
  String toString() => toDebugMap().toString();
}
