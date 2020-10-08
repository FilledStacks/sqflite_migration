import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferencesService _instance;

  static Future<SharedPreferencesService> getInstance(
      {bool enableLogs = false}) async {
    if (_instance == null) {
      _instance = SharedPreferencesService._(
          await SharedPreferences.getInstance(), enableLogs);
    }

    return _instance;
  }

  final enableLogs;
  final SharedPreferences _preferences;
  SharedPreferencesService._(
    this._preferences,
    this.enableLogs,
  );

  static const _DatabaseVersionKey = 'sqflite_migration_database_version_key';

  int get databaseVersion => _getFromDisk(_DatabaseVersionKey) ?? 0;

  set databaseVersion(int value) => _saveToDisk(_DatabaseVersionKey, value);

  void clearPreferences() {
    _preferences.clear();
  }

  dynamic _getFromDisk(String key) {
    var value = _preferences.get(key);
    if (enableLogs) print('key:$key value:$value');
    return value;
  }

  void _saveToDisk(String key, dynamic content) {
    if (enableLogs) print('key:$key value:$content');

    if (content is String) {
      _preferences.setString(key, content);
    }
    if (content is bool) {
      _preferences.setBool(key, content);
    }
    if (content is int) {
      _preferences.setInt(key, content);
    }
    if (content is double) {
      _preferences.setDouble(key, content);
    }
    if (content is List<String>) {
      _preferences.setStringList(key, content);
    }
  }
}
