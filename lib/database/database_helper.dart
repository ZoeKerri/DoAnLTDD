import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:doanltdd/models/todo.dart';

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

  if (maps.isEmpty) {
    // Danh sách mặc định
    List<ToDo> defaultTodos = [
      ToDo(id: "1", todoTitle: "Học Flutter", priority: 1, isNotify: false, date: DateTime.now()),
      ToDo(id: "2", todoTitle: "Tập thể dục", priority: 2, isNotify: false, date: DateTime.now()),
      ToDo(id: "3", todoTitle: "Đọc sách", priority: 2, isNotify: true, date: DateTime.now()),
      ToDo(id: "4", todoTitle: "Viết báo cáo", priority: 1, isNotify: false, date: DateTime.now()),
      ToDo(id: "5", todoTitle: "Đi ngủ sớm", priority: 3, isNotify: false, date: DateTime.now()),
    ];

    // Chèn dữ liệu mặc định vào database
    for (var todo in defaultTodos) {
      await db.insert('ToDo', todo.toMap());
    }

    return defaultTodos;
  }

  // Trả về danh sách từ database nếu có dữ liệu
  return List.generate(maps.length, (i) => ToDo.fromMap(maps[i]));
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
}
