/// IO implementation for desktop and mobile platforms
import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializePlatformDatabase() {
  // Initialize FFI for desktop platforms (macOS, Windows, Linux)
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // For Android and iOS, sqflite works natively, no initialization needed
}
