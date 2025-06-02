import 'package:firebase_database/firebase_database.dart';
import 'package:doanltdd/models/todo.dart';
import 'package:doanltdd/database/database_helper.dart';

class FirebaseDBService {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  //Create (update) - vì sao có update ở đây vì nó bao gồm cả remove tất cả dữ liệu và thêm dữ liệu mới vào trong db
  Future <void> create ({
    //khi mà ta tạo dữ liệu vào trong db firebase thì ta cần path để dẫn vào nơi mà dữ liệu sẽ được lưu vào 
    //ví dụ như dữ liệu lưu vào mấy cái data1 data2 mà mình đã tạo  
    required String path,
    //data là  dữ liệu mà mình muốn lưu vào path
    required Map<String,dynamic> data,
  })  async {
    //_firebaseDatabase.ref() khá tương tự với dấu & lấy địa chỉ trong c++ .child(path) chính là địa chỉ db firebase cần lưu
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    //ref.set(data) lưu dữ liệu vào địa chỉ tham chiếu đã được lấy
    await ref.set(data);
  }

  //Read
  Future<DataSnapshot?> read({required String path}) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    //snapshot là gì - snapshot là một đoạn dữ liệu trong path được cung cấp 
    final DataSnapshot snapshot = await ref.get();
    return snapshot.exists ? snapshot : null;
  }

  //update - mấy cái k biết đã được giải thích ở trên
  Future <void> update ({
    required String path,
    required Map<String,dynamic> data
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.update(data);
  }

  Future <void> delete ({required String path}) async {
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.remove();
  }

  /* //hàm read từ gpt 
  Future<Todo?> getTodoById(String id) async {
  final snapshot = await read(path: "todos/$id");
  if (snapshot != null) {
    final data = snapshot.value as Map;
    return Todo.fromJson(Map<String, dynamic>.from(data));
  }
  return null;
}
 */

  Future<void> createNewToDoWithOwner(ToDo todo, String ownerUserId) async {
    todo.collaborators = { ownerUserId: 'owner' };
    await create(path: "todos/${todo.id}", data: todo.toFirebaseMap());
    
    final updatedToDo = todo.copyWith(isSynced: true);
    await DatabaseHelper.instance.updateToDo(updatedToDo);
  }

  Future<void> updateCollaborators(String todoId, Map<String, String> collaborators) async {
    await update(path: "todos/$todoId", data: {
      'collaborators': collaborators,
    });

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('ToDo', where: 'id = ?', whereArgs: [todoId]);
    if (maps.isNotEmpty) {
      final old = ToDo.fromMap(maps.first);
      final updated = old.copyWith(
        collaborators: collaborators,
        isSynced: false,
      );
      await DatabaseHelper.instance.updateToDo(updated);
    }
  }

// Sync to firebase
  Future<void> syncToDoToFirebase() async {
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
          collaborators: todo.collaborators,
        );

        await dbHelper.updateToDo(updatedToDo);
      } catch (e) {
        print("Sync failed for ${todo.id}: $e");
      }
    }
  }

  //Sync from firebase
  Future<void> syncToDoFromFirebase(String currentUserId) async {
  final dbHelper = DatabaseHelper.instance;
  final ref = _firebaseDatabase.ref().child("todos");

  final snapshot = await ref.get();

  if (snapshot.exists) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    for (var entry in data.entries) {
      final todoMap = Map<String, dynamic>.from(entry.value);
      final firebaseToDo = ToDo.fromMap(todoMap);

      final collabs = firebaseToDo.collaborators ?? {};
      if (!collabs.containsKey(currentUserId)) {
        continue;
      }

      // Kiểm tra xem ToDo này đã có trong SQLite chưa
      final localToDos = await dbHelper.getAllToDos();
      final matchIndex = localToDos.indexWhere((t) => t.id == firebaseToDo.id);

      if (matchIndex != -1) {
        final localToDo = localToDos[matchIndex];

        // Nếu dữ liệu đã giống nhau thì bỏ qua
        if (firebaseToDo.updatedAt.isAtSameMomentAs(localToDo.updatedAt)) {
          continue;
        }

        // Nếu khác thì lấy bản mới nhất
        if (firebaseToDo.updatedAt.isAfter(localToDo.updatedAt)) {
            // Khi cập nhật local từ Firebase, giữ nguyên isNotify local cũ:
            final updated = firebaseToDo.copyWith(
              isSynced: true,
              isNotify: localToDo.isNotify,
            );
            await dbHelper.updateToDo(updated);
          }
      } else {
        final newLocal = firebaseToDo.copyWith(isSynced: true);
        await dbHelper.insertToDo(newLocal);
      }
    }
  }
}

}