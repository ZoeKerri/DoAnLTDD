class ToDo {
  String? id;
  String? todoTitle;
  int? priority;
  bool? isNotify;
  DateTime? date;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoTitle,
    required this.date,
    this.priority = 3,
    this.isNotify = false,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ToDoText': todoTitle,
      'priority': priority,
      'isNotify': isNotify == true ? 1 : 0,
      'date': date?.toIso8601String(),  
      'isDone': isDone ? 1 : 0,
    };
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'],
      todoTitle: map['ToDoText'],
      priority: map['priority'],
      isNotify: map['isNotify'] == 1,
      date: map['date'] != null
          ? (map['date'] is int 
              ? DateTime.fromMillisecondsSinceEpoch(map['date']) 
              : DateTime.tryParse(map['date']) ?? DateTime.fromMillisecondsSinceEpoch(int.parse(map['date'])))  
          : null,
      isDone: map['isDone'] == 1,
    );
  }

}
