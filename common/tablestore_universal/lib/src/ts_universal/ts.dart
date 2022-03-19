import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';
import 'package:tekartik_aliyun_tablestore_universal/tablestore_universal.dart';

export 'ts_stub.dart'
    if (dart.library.js) 'ts_node.dart'
    if (dart.library.io) 'ts_io.dart';

/// Implemented using sembast, avoir dependent import
Tablestore newTablestoreMemory() {
  return newTablestoreSembastMemory();
}

@Deprecated('use tablestoreUniversal instead')
Tablestore get tablestore => tablestoreUniversal;
