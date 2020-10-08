import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration/src/asset_reader.dart';
import 'package:sqflite_migration/src/locator.dart';
import 'package:sqflite_migration/src/shared_preferences_service.dart';

class SharedPreferencesMock extends Mock implements SharedPreferencesService {}

class AssetReaderMock extends Mock implements AssetReader {}

class DatabaseMock extends Mock implements Database {}

SharedPreferencesService getAndRegisterSharedPreferencesMock(
    {int databaseVersion = 0}) {
  _removeRegistrationIfExists<SharedPreferencesService>();
  var preferencesMock = SharedPreferencesMock();

  when(preferencesMock.databaseVersion).thenReturn(databaseVersion);

  locator.registerSingleton<SharedPreferencesService>(preferencesMock);
  return preferencesMock;
}

AssetReader getAndRegisterAssetReaderMock({String fileContent = ''}) {
  _removeRegistrationIfExists<AssetReader>();
  var mock = AssetReaderMock();

  when(mock.readFileFromBundle(any))
      .thenAnswer((realInvocation) => Future.value(fileContent));

  locator.registerSingleton<AssetReader>(mock);
  return mock;
}

Database getDatabaseMock() {
  var mock = DatabaseMock();
  return mock;
}

// Call this before any service registration helper. This is to ensure that if there
// is a service registered we remove it first. We register all services to remove boiler plate from tests
void _removeRegistrationIfExists<T>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
