import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';


import 'data_model.dart';

class DatabaseHelper {
  final _uuid = Uuid();
  static Database? _database; // Static variable to hold the database instance.

  // Getter method for accessing the database instance asynchronously.
  Future<Database> get database async {
    // If the database instance already exists, return it.
    if (_database != null) return _database!;

    // Otherwise, initialize the database and return the instance.
    _database = await initDatabase();
    return _database!;
  }

  // Initializes the database and creates the 'todos' table if it doesn't exist.
// Initializes the database and creates the 'todos' table if it doesn't exist.
  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id TEXT PRIMARY KEY, text TEXT, description TEXT, imagePath TEXT, createdDate TEXT, targetCompletionDate TEXT, done INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE todos ADD COLUMN done INTEGER DEFAULT 0');
        }
      },
      version: 3, // Increment the version number to apply schema changes.
    );
  }


  // Inserts a new todo item into the 'todos' table.
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    todo.id = _uuid.v4(); // Generate unique UUID
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  // Retrieves all todo items from the 'todos' table.
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    // Generates a list of Todo objects from the query result.
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['text'],
        description: maps[i]['description'],
        imagePath: maps[i]['imagePath'],
        createdDate: DateTime.parse(maps[i]['createdDate']), // Parse created date from string
        targetCompletionDate: maps[i]['targetCompletionDate'] != null ? DateTime.parse(maps[i]['targetCompletionDate']) : null, // Parse target completion date from string if not null
        done: maps[i]['done'] == 1, // Convert 1 to true, 0 to false
      );
    });
  }
  // Updates the 'done' state of a todo item in the 'todos' table.
  Future<void> updateTodoState(int id, bool done) async {
    final db = await database;
    await db.update(
      'todos',
      {'done': done ? 1 : 0}, // Converting boolean to SQLite-compatible integer.
      where: 'id = ?', // Specifies the condition for updating.
      whereArgs: [id], // Provides the values to replace placeholders in the condition.
    );
  }

  // Deletes a todo item from the 'todos' table.
  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?', // Specifies the condition for deletion.
      whereArgs: [id], // Provides the values to replace placeholders in the condition.
    );
  }
}
