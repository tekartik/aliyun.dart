import 'package:tekartik_aliyun_tablestore/tablestore.dart';
import 'package:tekartik_aliyun_tablestore_sembast/tablestore_sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:test/test.dart';

var options =
    TsClientOptions(endpoint: 'sembast', secretAccessKey: '', accessKeyId: '');
var tablestore = tablestoreSembastMemory;

void main() {
  tablesTest(options);
}

void tablesTest(TsClientOptions options) {
  late TsClient client;
  setUpAll(() {
    client = tablestore.client(options: options);
  });
  test('deleteTable', () async {
    var tableName = 'test_dummy_to_delete';
    try {
      await client.deleteTable(tableName);
    } catch (_) {}
    var names = await client.listTableNames();
    expect(names, isNot(contains(tableName)));
  });
  test('listTableNames', () async {
    expect(await client.listTableNames(), const TypeMatcher<List>());
  });

  var tableName = 'test_create1';

  Future createTable1() async {
    var tableName = 'test_create1';
    try {
      await client.deleteTable(tableName);
    } catch (_) {}
    var names = await client.listTableNames();
    if (!names.contains(tableName)) {
      await client.createTable(
          tableName,
          TsTableDescription(
              tableMeta: TsTableDescriptionTableMeta(
                  tableName: tableName,
                  primaryKeys: [
                TsPrimaryKeyDef(name: 'gid', type: TsColumnType.integer),
                TsPrimaryKeyDef(name: 'uid', type: TsColumnType.integer)
              ])));
    }
    names = await client.listTableNames();
    expect(names, contains(tableName));
  }

  test('createTable', () async {
    // We are limited in the number of create, test it well and sometimes delete!
    await createTable1();
  });
  test('describeTable', () async {
    // We are limited in the number of create, test it well and sometimes delete!
    await createTable1();
    //var names = await client.listTableNames();
    //expect(names, contains(tableName));

    var tableDescription = await client.describeTable(tableName);
    var tableMeta = tableDescription.tableMeta!;
    expect(tableMeta.tableName, tableName);

    // devPrint(jsonPretty(tableDescription.tableMeta.toMap()));
    // TODO only for node, to check soon!
    expect(tableMeta.primaryKeys!.length, 2);
    expect(tableMeta.primaryKeys![0].name, 'gid');
    expect(tableMeta.primaryKeys![0].type, TsColumnType.integer);
  });
}

/*
var params = {
  tableMeta: {
    tableName: 'sampleTable',
    primaryKey: [
      {
        name: 'gid',
        type: 'INTEGER'
      },
      {
        name: 'uid',
        type: 'INTEGER'
      }
    ]
  },
  reservedThroughput: {
    capacityUnit: {
      read: 0,
      write: 0
    }
  },
  tableOptions: {
    timeToLive: -1,// 数据的过期时间, 单位秒, -1代表永不过期. 假如设置过期时间为一年, 即为 365 * 24 * 3600.
    maxVersions: 1// 保存的最大版本数, 设置为1即代表每列上最多保存一个版本(保存最新的版本).
  },
  streamSpecification: {
    enableStream: true, //开启Stream
    expirationTime: 24 //Stream的过期时间，单位是小时，最长为168，设置完以后不能修改
  }
};*/
