import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_node/tablestore_node.dart';

/// The global node tablestore
Tablestore get tablestore => tablestoreNode;

/// Ignore arguments
Tablestore getTablestore({String? localRootPath, bool? localInMemory}) =>
    tablestore;
