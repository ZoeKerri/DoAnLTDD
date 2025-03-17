class ToDo {
  String? id;
  String? ToDoText;
  int ?priority;
  bool ?isNotify;
  DateTime? date;
  bool isDone;

  ToDo({
    required this.id,
    required this.ToDoText,
    required this.date,
    this.priority = 3,
    this.isNotify = false,
    this.isDone = false,
  });

  static List<ToDo> ToDoList(){
    return [
      ToDo(id: "1", ToDoText: "AAAA", date: DateTime(2025,3,9,12,30), isDone: true),
      ToDo(id: "2", ToDoText: "BBBBB", date: DateTime(2025,3,9)),
      ToDo(id: "3", ToDoText: "CCCCC", date: DateTime(2025,3,9)),
      ToDo(id: "4", ToDoText: "DDDDD", date: DateTime(2025,3,9)),
      ToDo(id: "5", ToDoText: "EEEEE", date: DateTime(2025,3,9)),
      ToDo(id: "6", ToDoText: "FFFFEEEE", date: DateTime(2025,3,9)),
    ];
  }
}