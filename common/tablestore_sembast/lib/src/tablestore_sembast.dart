import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/client_sembast.dart';
import 'package:tekartik_aliyun_tablestore_sembast/src/import.dart';

class TablestoreSembast with TablestoreMixin implements Tablestore {
  final DatabaseFactory factory;

  TablestoreSembast({required this.factory});

  @override
  TsClient client({TsClientOptions? options}) {
    return TsClientSembast(this, options);
  }

  @override
  String toString() {
    return 'TablestoreSembast()';
  }
}

/// In memory factory (shared memory)
final Tablestore tablestoreSembastMemory =
    getTablestoreSembast(factory: databaseFactoryMemory);

/// New in memory factory.
Tablestore newTablestoreSembastMemory() =>
    getTablestoreSembast(factory: newDatabaseFactoryMemory());

/// To call only once (per factory)
Tablestore getTablestoreSembast({required DatabaseFactory factory}) =>
    TablestoreSembast(factory: factory);

final debugTs = true; // devWarning(true); true for now
