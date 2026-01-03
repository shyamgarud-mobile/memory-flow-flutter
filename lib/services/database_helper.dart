/// Helper to initialize database factory for different platforms
library database_helper;

import 'package:sqflite/sqflite.dart';

// Conditional imports for platform-specific initialization
import 'database_helper_stub.dart'
    if (dart.library.io) 'database_helper_io.dart'
    if (dart.library.html) 'database_helper_web.dart';

/// Initialize the database factory for the current platform
void initializeDatabaseFactory() {
  initializePlatformDatabase();
}
