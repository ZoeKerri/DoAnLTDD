import 'todo.dart';

class ToDoRepository {
  final List<ToDo> _todos;

  ToDoRepository(this._todos);

  int countByDate(DateTime date) {
    return _todos.where((todo) =>
      todo.date != null &&
      todo.date!.year == date.year &&
      todo.date!.month == date.month &&
      todo.date!.day == date.day
    ).length;
  }

  int countByMonth(int month, int year) {
    return _todos.where((todo) =>
      todo.date != null &&
      todo.date!.year == year &&
      todo.date!.month == month
    ).length;
  }

  int countByYear(int year) {
    return _todos.where((todo) =>
      todo.date != null &&
      todo.date!.year == year
    ).length;
  }
}

extension ToDoRepositoryExtensions on ToDoRepository {
  List<ToDo> todosByDate(DateTime date) {
    return _todos.where((todo) =>
      todo.date != null &&
      todo.date!.year == date.year &&
      todo.date!.month == date.month &&
      todo.date!.day == date.day
    ).toList();
  }

  List<ToDo> todosByMonth(int month, int year) {
    return _todos.where((todo) =>
      todo.date != null &&
      todo.date!.year == year &&
      todo.date!.month == month
    ).toList();
  }

  List<ToDo> todosByYear(int year) {
    return _todos.where((todo) =>
      todo.date != null &&
      todo.date!.year == year
    ).toList();
  }
}