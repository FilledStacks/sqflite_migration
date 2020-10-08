import 'package:sqflite_migration_example/app/locator.dart';
import 'package:sqflite_migration_example/services/database_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../router.dart';

class StartupViewModel extends BaseViewModel {
  final _database = locator<DatabaseService>();
  final _navigationService = locator<NavigationService>();

  Future initialise() async {
    await _database.initialise();
    await _navigationService.navigateTo(Router.todo);
  }
}
