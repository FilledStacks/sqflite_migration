import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration_service/src/asset_reader.dart';
import 'package:sqflite_migration_service/src/shared_preferences_service.dart';

class MockSharedPreferencesService extends Mock
    implements SharedPreferencesService {
  MockSharedPreferencesService() {
    throwOnMissingStub(this);
  }

  @override
  String get databaseVersionKey => (super
          .noSuchMethod(Invocation.getter(#databaseVersionKey), returnValue: '')
      as String);
  @override
  int get databaseVersion =>
      (super.noSuchMethod(Invocation.getter(#databaseVersion), returnValue: 0)
          as int);
  @override
  set databaseVersion(int? value) =>
      super.noSuchMethod(Invocation.setter(#databaseVersion, value),
          returnValueForMissingStub: null);

  @override
  set databaseVersionKey(String? value) =>
      super.noSuchMethod(Invocation.setter(#databaseVersionKey, value),
          returnValueForMissingStub: null);
}

/// A class which mocks [AssetReader].
///
/// See the documentation for Mockito's code generation for more information.
class MockAssetReader extends Mock implements AssetReader {
  MockAssetReader() {
    throwOnMissingStub(this);
  }

  @override
  Future<String> readFileFromBundle(String? file) =>
      (super.noSuchMethod(Invocation.method(#readFileFromBundle, [file]),
          returnValue: Future.value('')) as Future<String>);
}

///
/// See the documentation for Mockito's code generation for more information.
class MockDatabase extends Mock implements Database {
  @override
  String get path =>
      (super.noSuchMethod(Invocation.getter(#path), returnValue: '') as String);
  @override
  bool get isOpen =>
      (super.noSuchMethod(Invocation.getter(#isOpen), returnValue: false)
          as bool);
  @override
  Future<void> close() => (super.noSuchMethod(Invocation.method(#close, []),
      returnValue: Future.value(null),
      returnValueForMissingStub: Future.value()) as Future<void>);
  @override
  Future<T> transaction<T>(Future<T> Function(Transaction)? action,
          {bool? exclusive}) =>
      (super.noSuchMethod(
          Invocation.method(#transaction, [action], {#exclusive: exclusive}),
          returnValue: Future.value(null)) as Future<T>);
  @override
  Future<int> getVersion() =>
      (super.noSuchMethod(Invocation.method(#getVersion, []),
          returnValue: Future.value(0)) as Future<int>);
  @override
  Future<void> setVersion(int? version) =>
      (super.noSuchMethod(Invocation.method(#setVersion, [version]),
          returnValue: Future.value(null),
          returnValueForMissingStub: Future.value()) as Future<void>);
  @override
  Future<T> devInvokeMethod<T>(String? method, [dynamic arguments]) => (super
      .noSuchMethod(Invocation.method(#devInvokeMethod, [method, arguments]),
          returnValue: Future.value(null)) as Future<T>);
  @override
  Future<T> devInvokeSqlMethod<T>(String? method, String? sql,
          [List<Object?>? arguments]) =>
      (super.noSuchMethod(
          Invocation.method(#devInvokeSqlMethod, [method, sql, arguments]),
          returnValue: Future.value(null)) as Future<T>);

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
      [List<Object?>? arguments]) {
    return super.noSuchMethod(
      Invocation.method(#rawQuery, [sql, arguments]),
      returnValue: Future<List<Map<String, Object?>>>.value([]),
      returnValueForMissingStub: Future<List<Map<String, Object?>>>.value([]),
    ) as Future<List<Map<String, Object?>>>;
  }
}
