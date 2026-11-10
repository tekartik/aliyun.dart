/// Aliyun Tablestore on a sembast database: [newTablestoreSembastMemory]
/// (empty, in memory), [tablestoreSembastMemory] (shared) and
/// [getTablestoreSembast] (any sembast factory). Every platform.
library;

export 'src/tablestore_sembast.dart'
    show
        getTablestoreSembast,
        tablestoreSembastMemory,
        newTablestoreSembastMemory;
