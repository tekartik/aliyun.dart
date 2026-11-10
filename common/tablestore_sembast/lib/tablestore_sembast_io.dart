/// Aliyun Tablestore on a sembast file database (Dart VM):
/// [tablestoreSembastIo] and [getTablestoreSembastIo].
library;

import 'package:sembast/sembast_io.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';

/// File databases under `.dart_tool/tekartik_aliyun/tablestore/` of the
/// current directory (relative instance names).
final Tablestore tablestoreSembastIo = getTablestoreSembast(
  factory: databaseFactoryIo,
);

/// Get an io factory
Tablestore getTablestoreSembastIo({String? rootPath}) =>
    getTablestoreSembast(factory: createDatabaseFactoryIo(rootPath: rootPath));
