import 'package:sqflite_migration_example/app/locator.dart';
import 'package:sqflite_migration_example/models/todo.dart';
import 'package:sqflite_migration_example/services/database_service.dart';
import 'package:stacked/stacked.dart';

class TodoViewModel extends FutureViewModel<List<Todo>> {
  final _database = locator<DatabaseService>();

  Future addTodo(String title, String description) async {
    await runBusyFuture(_database.addTodo(
      title: title,
      description: description,
    ));

    // Initialise will rerun the initial FutureViewModel logic which will
    // 1. Run the Future provided to futureToRun()
    // 2. Store the value returned from that future in the data property
    await initialise();
  }

  @override
  Future<List<Todo>> futureToRun() => _database.getTodos();

  Future setCompleteForItem(int index, bool value) async {
    await _database.updateCompleteForTodo(id: data[index].id, complete: value);

    // Initialise will rerun the initial FutureViewModel logic which will
    // 1. Run the Future provided to futureToRun()
    // 2. Store the value returned from that future in the data property
    await initialise();
  }
}
