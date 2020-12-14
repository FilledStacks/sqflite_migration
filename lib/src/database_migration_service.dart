import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration_service/src/asset_reader.dart';
import 'package:sqflite_migration_service/src/exceptions/sql_migration_exception.dart';
import 'package:sqflite_migration_service/src/shared_preferences_service.dart';
import 'package:sqflite_migration_service/src/string_helpers.dart';

import 'locator.dart';

/// Contains Database migration functionality
class DatabaseMigrationService {
  SharedPreferencesService _sharedPreferences;
  AssetReader _assetReader;

  DatabaseMigrationService();

  bool _setupComplete = false;

  @visibleForTesting
  List<String> getMigrationQueriesFromScript(String scriptContent,
      {String fileName}) {
    try {
      return scriptContent
          .split(';')
          .map((queryMultiLine) =>
              queryMultiLine.split('\n').map((e) => e.trim()).toList().join(''))
          .where((element) => !isNullOrEmpty(element))
          .toList();
    } catch (e) {
      throw SqlMigrationException(
          'Content from assets/sql/$fileName could not be divided into queries. Check the content in assets/sql/$fileName and make sure it follows the correct format.');
    }
  }

  /// Sets up the locator and assigns the instances required for this class
  ///
  /// Trying out a new method to avoid having any kind of initialisation logic or
  /// doing a setup by calling the .getInstance method using the singleton pattern.
  ///
  /// Using this we will now be able to simply register the DatabaseMigrationService
  /// then call runMigration with the required values and it'll work. No setup call needed
  /// from the user of the package
  Future _setupLocator() async {
    // First check if the classes are registered
    if (!locator.isRegistered<AssetReader>()) {
      locator.registerSingleton(AssetReader());
    }

    if (!locator.isRegistered<SharedPreferencesService>()) {
      var sharedPreferences = await SharedPreferencesService.getInstance();
      locator.registerSingleton(sharedPreferences);
    }

    // If the assetReader is null get it from the locator
    if (_assetReader == null) {
      _assetReader = locator<AssetReader>();
    }

    // If the shared preferences is null get it from the locator
    if (_sharedPreferences == null) {
      _sharedPreferences = locator<SharedPreferencesService>();
    }
  }

  /// Resets the database version to 0
  void resetVersion() {
    _sharedPreferences.databaseVersion = 0;
  }

  /// Runs the migrations on the [database] using the files listed in the [migrationFiles] list.
  ///
  /// Set verbose: true if you want to print out all migration logs
  Future runMigration(
    Database database, {
    @required List<String> migrationFiles,
    bool verbose = false,
    String databaseVersionKey,
      
    /// When a migration fails update the version number to the one that failed and continue.
    /// This should be used when you have migrations that might fail due to previous errors in
    /// your migration logic but you don't want that failing migration to keep running on every start.
    bool skipFailingMigration = false,
  }) async {
    // Only perform the setup once when calling runMigration
    if (!_setupComplete) {
      await _setupLocator();
      _setupComplete = true;
    }

    if (databaseVersionKey != null) {
      _sharedPreferences.databaseVersionKey = databaseVersionKey;
    }

    if (verbose) {
      print('DatabaseMigrationService - Shared Preferences Key: ${_sharedPreferences.databaseVersionKey}');
    }

    // #1: Get the current database version from Shared Preferences
    var databaseVersion = _sharedPreferences.databaseVersion;

    if (verbose) {
      print('DatabaseMigrationService - Database Version: $databaseVersion');
    }

    // #2: Loop through the migration files supplied
    for (var file in migrationFiles) {
      var migrationVersion = int.tryParse(file.split('_').first);

      // #3: if the migration file version > databaseService
      if (migrationVersion > databaseVersion) {
        if (verbose) {
          print(
              'DatabaseMigrationService - Run migration for $file. This will take us from database version $databaseVersion to $migrationVersion');
        }
        // #4: Read the migration file from assets
        var migrationData = await _assetReader.readFileFromBundle(file);

        // #5: Get the individual queries from the migration script
        var migrationQueries =
            getMigrationQueriesFromScript(migrationData, fileName: file);

        try {
          for (var query in migrationQueries) {
            if (verbose) {
              print('DatabaseMigrationService - Run migration query: $query');
            }
            // #6: Run the migration by applying all the individual queries for the migration script
            await database.rawQuery(query);
          }
          if (verbose) {
            print(
                'DatabaseMigrationService - Migration complete from $databaseVersion to $migrationVersion... update databaseService to $migrationVersion');
          }

          // #7: Update the database version
          _sharedPreferences.databaseVersion = migrationVersion;
        } catch (exception) {
          print(
              'DatabaseMigrationService - Migration from $databaseVersion to $migrationVersion didn\'t run.');

          if (skipFailingMigration) {
            print(
                'DatabaseMigrationService - Even though migration failed we\'re updating the databaseVersion from $databaseVersion to $migrationVersion');
            _sharedPreferences.databaseVersion = migrationVersion;
          }

          print('DatabaseMigrationService - Exception:$exception');

          continue;
        }
      }
    }
  }
}
