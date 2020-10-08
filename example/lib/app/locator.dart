import 'package:get_it/get_it.dart';
import 'package:sqflite_migration_example/services/database_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:sqflite_migration_service/sqflite_migration_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());

  locator.registerLazySingleton(() => DatabaseMigrationService());
  locator.registerLazySingleton(() => DatabaseService());
}
