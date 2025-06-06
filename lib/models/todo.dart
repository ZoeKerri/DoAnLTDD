class ToDo {
  String? id;
  String? todoTitle;
  int? priority;
  bool? isNotify;
  DateTime? date;
  bool isDone;

  DateTime updatedAt;                 // Thời điểm cập nhật cuối cùng
  bool isSynced;                      // Đã đồng bộ với Firebase chưa? chưa thì up lên firebase
  Map<String, String>? collaborators; // Danh sách collaborators

  ToDo({
    required this.id,
    required this.todoTitle,
    required this.date,
    this.priority = 3,
    this.isNotify = false,
    this.isDone = false,
    DateTime? updatedAt,
    this.isSynced = false,
    Map<String, String>? collaborators,
  }) : 
    updatedAt = updatedAt ?? DateTime.now(), // Nếu không có thì gán thời điểm hiện tại
    collaborators = collaborators ?? {};

  ToDo copyWith({
    String? id,
    String? todoTitle,
    int? priority,
    bool? isNotify,
    DateTime? date,
    bool? isDone,
    DateTime? updatedAt,
    bool? isSynced,
    Map<String, String>? collaborators,
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
      collaborators: collaborators ?? this.collaborators,
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
      'collaborators': collaborators != null 
         ? collaborators!.entries.map((e) => '${e.key}:${e.value}').join(',') 
         : '',
    };
  }

  // Chuyển từ Map trong SQLite thành object
  factory ToDo.fromMap(Map<String, dynamic> map) {
    Map<String, String> collabMap = {};
    if ((map['collaborators'] as String).isNotEmpty) {
      for (var pair in (map['collaborators'] as String).split(',')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          collabMap[parts[0]] = parts[1];
        }
      }
    }
    
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
      collaborators: collabMap,
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
      'collaborators': collaborators ?? {},
    };
  }

  factory ToDo.fromFirebaseMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'],
      todoTitle: map['todoTitle'],
      priority: map['priority'],
      isNotify: false,
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : null,
      isDone: map['isDone'] ?? false,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      isSynced: true,
      collaborators: Map<String, String>.from(map['collaborators'] ?? {}),
    );
  }
}
