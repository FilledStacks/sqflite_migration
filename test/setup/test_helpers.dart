import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration_service/src/asset_reader.dart';
import 'package:sqflite_migration_service/src/locator.dart';
import 'package:sqflite_migration_service/src/shared_preferences_service.dart';

import 'mocked_classes.dart';

const String defaultDatabaseVersionKey = 'database_version_key';

SharedPreferencesService getAndRegisterSharedPreferencesMock({
  int databaseVersion = 0,
  String databaseVersionKey = defaultDatabaseVersionKey,
}) {
  _removeRegistrationIfExists<SharedPreferencesService>();
  var preferencesMock = MockSharedPreferencesService();

  when(preferencesMock.databaseVersion).thenReturn(databaseVersion);
  when(preferencesMock.databaseVersionKey).thenReturn(databaseVersionKey);

  locator.registerSingleton<SharedPreferencesService>(preferencesMock);
  return preferencesMock;
}

AssetReader getAndRegisterAssetReaderMock({String? fileContent = ''}) {
  _removeRegistrationIfExists<AssetReader>();
  var mock = MockAssetReader();

  when(mock.readFileFromBundle(any))
      .thenAnswer((realInvocation) => Future.value(fileContent));

  locator.registerSingleton<AssetReader>(mock);
  return mock;
}

Database getDatabaseMock() {
  var mock = MockDatabase();
  return mock;
}

// Call this before any service registration helper. This is to ensure that if there
// is a service registered we remove it first. We register all services to remove boiler plate from tests
void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
