/// One Aliyun Tablestore for the Dart VM (a sembast mock) and nodejs (the real
/// service): [tablestoreUniversal], [getTablestore], [newTablestoreMemory] and
/// the re-exported `tekartik_aliyun_tablestore` API.
library;

export 'package:tekartik_aliyun_tablestore/tablestore.dart';

export 'src/ts_universal/ts.dart'
    show tablestore, getTablestore, newTablestoreMemory, tablestoreUniversal;
