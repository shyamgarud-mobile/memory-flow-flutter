/// Web implementation (sqflite not supported on web)
void initializePlatformDatabase() {
  // Web platform doesn't support sqflite
  throw UnsupportedError('SQLite is not supported on web platform');
}
