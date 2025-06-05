import 'package:firebase_database/firebase_database.dart';
import 'package:doanltdd/models/todo.dart';
import 'package:doanltdd/database/database_helper.dart';
class DatabaseService {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> create ({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.set(data);
  }

  Future<DataSnapshot?> read({
    required String path
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    final DataSnapshot snapshot =  await ref.get();
    return snapshot.exists ? snapshot : null;
  }

  Future<void> update ({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.update(data);
  }

  Future<void> delete ({
    required String path,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.remove();
  }

  Future<void> syncToFirebase() async {
    final dbHelper = DatabaseHelper.instance;
    final unsyncedTodos = await dbHelper.getUnsyncedToDos();

    for (var todo in unsyncedTodos) {

      try {
        await create(path: "todos/${todo.id}", data: todo.toMap());
        final updatedToDo = ToDo(
          id: todo.id,
          todoTitle: todo.todoTitle,
          date: todo.date,
          priority: todo.priority ?? 3,
          isNotify: todo.isNotify ?? false,
          isDone: todo.isDone,
          updatedAt: DateTime.now(),
          isSynced: true,
        );

        await dbHelper.updateToDo(updatedToDo);
      } catch (e) {
        print("Sync failed for ${todo.id}: $e");
      }
    }
  }

  Future<void> syncFromFirebase() async {
    final dbHelper = DatabaseHelper.instance;
    final ref = _firebaseDatabase.ref().child("todos");

    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (var entry in data.entries) {
        final todoMap = Map<String, dynamic>.from(entry.value);
        final firebaseToDo = ToDo.fromMap(todoMap);

        // Kiểm tra xem ToDo này đã có trong SQLite chưa
        final localToDos = await dbHelper.getAllToDos();
        final matchIndex = localToDos.indexWhere((t) => t.id == firebaseToDo.id);

        if (matchIndex != -1) {
          final localToDo = localToDos[matchIndex];

        // Nếu dữ liệu đã giống nhau thì bỏ qua
          if (firebaseToDo.updatedAt.isAtSameMomentAs(localToDo.updatedAt)) {
            return;
          }

        // Nếu khác thì lấy bản mới nhất
          final newerToDo = firebaseToDo.updatedAt.isAfter(localToDo.updatedAt)
              ? firebaseToDo.copyWith(isSynced: true)
              : localToDo.copyWith(isSynced: true);

          await dbHelper.updateToDo(newerToDo);
        }
      }
    }
  }
}
