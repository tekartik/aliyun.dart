/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:sembast/sembast_io.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';

final Tablestore tablestoreSembastIo = getTablestoreSembast(
  factory: databaseFactoryIo,
);

/// Get an io factory
Tablestore getTablestoreSembastIo({String? rootPath}) =>
    getTablestoreSembast(factory: createDatabaseFactoryIo(rootPath: rootPath));

// TODO: Export any libraries intended for clients of this package.
