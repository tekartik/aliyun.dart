export 'ts_node_universal_stub.dart'
    if (dart.library.js) 'ts_node_universal_node.dart'
    if (dart.library.io) 'ts_node_universal_io.dart';
