class SqlMigrationException implements Exception {
  final String message;
  
  SqlMigrationException(this.message);
}
