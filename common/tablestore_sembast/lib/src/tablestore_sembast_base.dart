import 'package:sembast/sembast.dart';
import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:meta/meta.dart';

class TablestoreSembast with TablestoreMixin implements Tablestore {
  final DatabaseFactory factory;

  TablestoreSembast({@required this.factory});
  @override
  TsClient client({TsClientOptions options}) {
    // TODO: implement client
    throw UnimplementedError();
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
