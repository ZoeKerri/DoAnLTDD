import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:doanltdd/models/todo.dart';
import 'package:doanltdd/models/users.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    print("⏳ Getting database path...");
    final dbPath = await getDatabasesPath();
    print("📂 Database path retrieved: $dbPath"); // Nếu không in ra => lỗi

    final path = join(dbPath, filePath);
    print("📂 Full database path: $path");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }



  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ToDo (
        id TEXT PRIMARY KEY,
        ToDoText TEXT NOT NULL,
        priority INTEGER,
        isNotify INTEGER,
        date TEXT,
        isDone INTEGER,
        updatedAt TEXT,
        isSynced INTEGER,
        collaborators TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }
  
  //k có kiểu boolean nên xài interger

  // Thêm ToDo vào SQLite
  Future<int> insertToDo(ToDo todo) async {
    final db = await database;
    return await db.insert('ToDo', 
    todo.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lấy danh sách tất cả ToDo
  Future<int> deleteTodo(String id) async {
    final db = await database;
    return await db.delete(
      'ToDo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hàm lấy tất cả ToDo và tự động cập nhật trạng thái quá hạn
  Future<List<ToDo>> getAllToDos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ToDo');

    final DateTime now = DateTime.now(); // Lấy thời gian hiện tại
    List<ToDo> todos = List.generate(maps.length, (i) => ToDo.fromMap(maps[i]));
    List<ToDo> todosToUpdateInDb = []; 

    for (int i = 0; i < todos.length; i++) {
      ToDo todo = todos[i];

      if (todo.date != null && !todo.isDone!) {
        if (todo.date!.isBefore(now)) {
          ToDo updatedTodo = todo.copyWith(
            isDone: true,
            updatedAt: DateTime.now(), 
            isSynced: false, 
          );
          todos[i] = updatedTodo; 
          todosToUpdateInDb.add(updatedTodo); 
        }
      }
    }

    for (ToDo todo in todosToUpdateInDb) {
      await updateToDo(todo); 
    }

    return todos; 
  }


  // Cập nhật trạng thái hoàn thành
  Future<int> updateToDo(ToDo todo) async {
    final db = await database;
    return await db.update(
      'ToDo',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Xóa ToDo theo ID
  Future<int> deleteToDo(String id) async {
    final db = await database;
    return await db.delete('ToDo', where: 'id = ?', whereArgs: [id]);
  }

  // lấy list todo chưa được đồng bộ ở local up lên firebase 
  Future<List<ToDo>> getUnsyncedToDos() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'ToDo',
    where: 'isSynced = ?',
    whereArgs: [0],
  );
  return List.generate(maps.length, (i) => ToDo.fromMap(maps[i]));
}
  Future<int> insertUser(User user) async {
    final db = await database;
    final id = await db.insert('users', 
    user.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Tìm User theo tên và mật khẩu
  Future<User?> getUserByNameAndPassword(String name, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Tìm User theo ID
  Future<User?> getUserById(String id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [int.tryParse(id)],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
}
