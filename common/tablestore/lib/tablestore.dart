/// Support for doing something awesome.
///
/// More dartdocs go here.

export 'src/ts_tablestore.dart' show Tablestore;
export 'src/ts_client.dart'
    show
        TsClient,
        TsClientOptions,
        TsTableDescription,
        TsPrimaryKey,
        TsTableCapacityUnit,
        TsTableDescriptionOptions,
        TsTableDescriptionReservedThroughput,
        TsTableDescriptionTableMeta,
        TsColumnType,
        TsException,
        tableCreateCapacityUnitDefault,
        tableCreateOptionsDefault,
        tableCreateReservedThroughputDefault;
export 'src/ts_row.dart'
    show
        TsGetRowRequest,
        TsGetRowResponse,
        TsGetRowResponseExt,
        TsPutRowRequest,
        TsPutRowResponse,
        TsPutRowResponseExt,
        TsGetRow,
        TsCondition;

export 'src/ts_value_type.dart' show TsValueLong;
export 'src/ts_column.dart' show TsKeyValue, TsAttribute;
