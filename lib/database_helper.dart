import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'data_model.dart';

class DatabaseHelper {
  final _uuid = Uuid();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo_database.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE todos(id TEXT PRIMARY KEY, text TEXT, description TEXT, imagePath TEXT, createdDate TEXT, targetCompletionDate TEXT, done INTEGER)',
        );
        db.execute(
          'CREATE TABLE archived_todos(id TEXT PRIMARY KEY, text TEXT, description TEXT, imagePath TEXT, createdDate TEXT, targetCompletionDate TEXT, done INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE todos ADD COLUMN done INTEGER DEFAULT 0');
        }
      },
      version: 4,
    );
  }

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    todo.id = _uuid.v4();
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['text'],
        description: maps[i]['description'],
        imagePath: maps[i]['imagePath'],
        createdDate: DateTime.parse(maps[i]['createdDate']),
        targetCompletionDate: maps[i]['targetCompletionDate'] != null ? DateTime.parse(maps[i]['targetCompletionDate']) : null,
        done: maps[i]['done'] == 1,
      );
    });
  }

  Future<void> updateTodoState(String id, bool done) async {
    final db = await database;
    await db.update(
      'todos',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertArchivedTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      'archived_todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getArchivedTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('archived_todos');
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['text'],
        description: maps[i]['description'],
        imagePath: maps[i]['imagePath'],
        createdDate: DateTime.parse(maps[i]['createdDate']),
        targetCompletionDate: maps[i]['targetCompletionDate'] != null ? DateTime.parse(maps[i]['targetCompletionDate']) : null,
        done: maps[i]['done'] == 1,
      );
    });
  }

  Future<Todo?> getTodoById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Todo(
      id: maps[0]['id'],
      title: maps[0]['text'],
      description: maps[0]['description'],
      imagePath: maps[0]['imagePath'],
      createdDate: DateTime.parse(maps[0]['createdDate']),
      targetCompletionDate: maps[0]['targetCompletionDate'] != null
          ? DateTime.parse(maps[0]['targetCompletionDate'])
          : null,
      done: maps[0]['done'] == 1,
    );
  }

  Future<Todo?> getArchivedTodoById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'archived_todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Todo(
      id: maps[0]['id'],
      title: maps[0]['text'],
      description: maps[0]['description'],
      imagePath: maps[0]['imagePath'],
      createdDate: DateTime.parse(maps[0]['createdDate']),
      targetCompletionDate: maps[0]['targetCompletionDate'] != null
          ? DateTime.parse(maps[0]['targetCompletionDate'])
          : null,
      done: maps[0]['done'] == 1,
    );
  }

  Future<void> deleteArchivedTodo(String id) async {
    final db = await database;
    await db.delete(
      'archived_todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


// Moves an archived todo item from the 'archived_todos' table back to the 'todos' table.
  Future<void> unarchiveTodo(String id) async {
    final db = await database;
    final archivedTodo = await getTodoById(id);
    if (archivedTodo != null) {
      await db.insert(
        'todos',
        archivedTodo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Delete the todo item from the 'archived_todos' table after moving it.
      await deleteArchivedTodo(id);
    }
  }

}
