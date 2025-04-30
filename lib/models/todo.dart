class ToDo {
  String? id;
  String? todoTitle;
  int? priority;
  bool? isNotify;
  DateTime? date;
  bool isDone;

  DateTime updatedAt; // Thời điểm cập nhật cuối cùng
  bool isSynced;      // Đã đồng bộ với Firebase chưa? chưa thì up lên firebase

  ToDo({
    required this.id,
    required this.todoTitle,
    required this.date,
    this.priority = 3,
    this.isNotify = false,
    this.isDone = false,
    DateTime? updatedAt,
    this.isSynced = false,
  }) : updatedAt = updatedAt ?? DateTime.now(); // Nếu không có thì gán thời điểm hiện tại

  //chưa hiểu lắm về cơ chế copyWith để xem sau
  ToDo copyWith({
    String? id,
    String? todoTitle,
    int? priority,
    bool? isNotify,
    DateTime? date,
    bool? isDone,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return ToDo(
      id: id ?? this.id,
      todoTitle: todoTitle ?? this.todoTitle,
      priority: priority ?? this.priority,
      isNotify: isNotify ?? this.isNotify,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Chuyển sang Map để lưu vào SQLite hoặc Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ToDoText': todoTitle,
      'priority': priority,
      'isNotify': isNotify == true ? 1 : 0,
      'date': date?.toIso8601String(),
      'isDone': isDone ? 1 : 0,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Chuyển từ Map trong SQLite thành object
  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'],
      todoTitle: map['ToDoText'],
      priority: map['priority'],
      isNotify: map['isNotify'] == 1,
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : null,
      isDone: map['isDone'] == 1,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      isSynced: map['isSynced'] == 1,
    );
  }

  // Dành cho Firebase (nếu cần convert riêng biệt)
  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'todoTitle': todoTitle,
      'priority': priority,
      'isNotify': isNotify,
      'date': date?.toIso8601String(),
      'isDone': isDone,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}