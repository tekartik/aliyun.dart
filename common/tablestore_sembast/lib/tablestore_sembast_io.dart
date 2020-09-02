/// Support for doing something awesome.
///
/// More dartdocs go here.
library tekartik_aliyun_tablestore_sembast_io;

import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/tablestore_sembast_base.dart';
import 'package:sembast/sembast_io.dart';

final Tablestore tablestoreSembastIo =
    getTablestoreSembast(factory: databaseFactoryIo);

/// Get an io factory
Tablestore getTablestoreSembastIo({String rootPath}) =>
    getTablestoreSembast(factory: createDatabaseFactoryIo(rootPath: rootPath));

// TODO: Export any libraries intended for clients of this package.
