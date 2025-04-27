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
        isDone INTEGER
      )
    ''');

    // Thêm bảng Users
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT
      )
    ''');
  }

  //k có kiểu boolean nên xài interger

  // Thêm ToDo vào SQLite
  Future<int> insertToDo(ToDo todo) async {
    final db = await database;
    return await db.insert('ToDo', todo.toMap());
  }

  // Lấy danh sách tất cả ToDo
  Future<List<ToDo>> getAllToDos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ToDo');

    return List.generate(maps.length, (i) {
      return ToDo.fromMap(maps[i]);
    });
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

  // Đăng ký người dùng
  Future<int> registerUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert('Users', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  // Đăng nhập người dùng
  Future<bool> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'Users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

  // Kiểm tra email đã tồn tại chưa
  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Thêm User mới
Future<int> insertUser(User user) async {
  final db = await database;
  return await db.insert('users', user.toMap());
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

}

