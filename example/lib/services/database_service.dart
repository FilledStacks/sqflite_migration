import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration_example/app/locator.dart';
import 'package:sqflite_migration/sqflite_migration.dart';
import 'package:sqflite_migration_example/models/todo.dart';

const DB_NAME = 'sqflite_migration_example.sqlite';

const String TodoTableName = 'todos';

/// This class wraps the sqflite database functionality for use throughout the app.
class DatabaseService {
  final _migrationService = locator<DatabaseMigrationService>();

  Database _database;

  /// Initialises the database and runs the migration schema using the
  /// [DatabaseMigrationService]
  Future initialise() async {
    _database = await openDatabase(DB_NAME, version: 1);

    await _migrationService.runMigration(
      _database,
      migrationFiles: [
        '1_create_schema.sql',
        '2_add_description.sql',
      ],
    );
  }

  /// Gets all the Todo's from the database
  Future<List<Todo>> getTodos() async {
    List<Map> todoResults = await _database.query(TodoTableName);
    return todoResults.map((todo) => Todo.fromJson(todo)).toList();
  }

  /// Adds a new todo into the database
  Future addTodo({String title, String description}) async {
    try {
      await _database.insert(
          TodoTableName,
          Todo(
            title: title,
            description: description,
          ).toJson());
    } catch (e) {
      print('Could not insert the todo: $e');
    }
  }

  /// Updates todo completed value
  Future updateCompleteForTodo({int id, bool complete}) async {
    try {
      await _database.update(
          TodoTableName,
          {
            'complete': complete ? 1 : 0,
          },
          where: 'id = ?',
          whereArgs: [id]);
    } catch (e) {
      print('Could not update the todo: $e');
    }
  }
}
