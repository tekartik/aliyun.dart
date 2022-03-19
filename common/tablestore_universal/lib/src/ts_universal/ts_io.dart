import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast_io.dart';

Tablestore get tablestoreUniversal => tablestoreSembastMemory;

/// localRootPath and localInMemory are only for local testing
Tablestore getTablestore({String? localRootPath, bool? localInMemory}) {
  if (localInMemory ?? false) {
    return tablestoreUniversal;
  }
  return getTablestoreSembastIo(rootPath: localRootPath);
}
