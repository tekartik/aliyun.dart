import 'package:sembast/sembast.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:meta/meta.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/client_sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_aliyun_tablestore/src/mixin/ts_tablestore_mixin.dart';

class TablestoreSembast with TablestoreMixin implements Tablestore {
  final DatabaseFactory factory;

  TablestoreSembast({@required this.factory});
  @override
  TsClient client({TsClientOptions options}) {
    return TsClientSembast(this, options);
  }

  @override
  String toString() {
    return 'TablestoreSembast()';
  }
}

/// In memory factory.
final tablestoreSembastMemory =
    getTablestoreSembast(factory: databaseFactoryMemory);

/// To call only once (per factory)
Tablestore getTablestoreSembast({@required DatabaseFactory factory}) =>
    TablestoreSembast(factory: factory);

final debugTs = true; // devWarning(true); true for now
