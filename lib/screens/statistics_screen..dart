import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/todo.dart';
import '../models/todostatistics.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

enum FilterType { day, month, year, all }
enum StatusFilter { all, done, notDone }

class StatisticsScreen extends StatefulWidget {
  final List<ToDo> todos;
  const StatisticsScreen({super.key, required this.todos});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime selectedDate = DateTime.now();
  FilterType filterType = FilterType.day;
  StatusFilter statusFilter = StatusFilter.all;

  int completedToday = 0;
  int uncompletedToday = 0;
  int completedThisWeek = 0;
  int uncompletedThisWeek = 0;
  int completedThisMonth = 0;
  int uncompletedThisMonth = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final todos = await DatabaseHelper.instance.getAllToDos();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    int doneToday = 0, undoneToday = 0;
    int doneWeek = 0, undoneWeek = 0;
    int doneMonth = 0, undoneMonth = 0;

    for (var todo in todos) {
      if (todo.date == null) continue;
      final todoDay = DateTime(todo.date!.year, todo.date!.month, todo.date!.day);
      bool isToday = todoDay == today;
      bool isThisWeek = todoDay.isAfter(startOfWeek.subtract(const Duration(days: 1)));
      bool isThisMonth = todoDay.isAfter(startOfMonth.subtract(const Duration(days: 1)));

      if (isToday) {
        if (todo.isDone) {
          doneToday++;
        } else {
          undoneToday++;
        }
      }
      if (isThisWeek) {
        if (todo.isDone) {
          doneWeek++;
        } else {
          undoneWeek++;
        }
      }
      if (isThisMonth) {
        if (todo.isDone) {
          doneMonth++;
        } else {
          undoneMonth++;
        }
      }
    }

    setState(() {
      completedToday = doneToday;
      uncompletedToday = undoneToday;
      completedThisWeek = doneWeek;
      uncompletedThisWeek = undoneWeek;
      completedThisMonth = doneMonth;
      uncompletedThisMonth = undoneMonth;
    });
  }

  List<ToDo> getFilteredTodos() {
    final repo = ToDoRepository(widget.todos);
    List<ToDo> filtered;

    switch (filterType) {
      case FilterType.day:
        filtered = repo.todosByDate(selectedDate);
        break;
      case FilterType.month:
        filtered = repo.todosByMonth(selectedDate.month, selectedDate.year);
        break;
      case FilterType.year:
        filtered = repo.todosByYear(selectedDate.year);
        break;
      case FilterType.all:
        filtered = widget.todos;
        break;
    }

    switch (statusFilter) {
      case StatusFilter.done:
        return filtered.where((todo) => todo.isDone).toList();
      case StatusFilter.notDone:
        return filtered.where((todo) => !todo.isDone).toList();
      case StatusFilter.all:
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = getFilteredTodos();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 195, 255), 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () {
            Navigator.of(context).pop(); 
          },
        ),
        title: const Text(
          'Thống kê ToDo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: selectedDate,
                    selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDate = selected;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<FilterType>(
                          value: filterType,
                          onChanged: (FilterType? newType) {
                            if (newType != null) {
                              setState(() => filterType = newType);
                            }
                          },
                          items: FilterType.values.map((FilterType type) {
                            return DropdownMenuItem<FilterType>(
                              value: type,
                              child: Text({
                                FilterType.day: 'Ngày',
                                FilterType.month: 'Tháng',
                                FilterType.year: 'Năm',
                                FilterType.all: 'Tất cả'
                              }[type]!),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<StatusFilter>(
                          value: statusFilter,
                          onChanged: (StatusFilter? newStatus) {
                            if (newStatus != null) {
                              setState(() => statusFilter = newStatus);
                            }
                          },
                          items: StatusFilter.values.map((StatusFilter status) {
                            return DropdownMenuItem<StatusFilter>(
                              value: status,
                              child: Text({
                                StatusFilter.all: 'Tất cả',
                                StatusFilter.done: 'Đã hoàn thành',
                                StatusFilter.notDone: 'Chưa hoàn thành'
                              }[status]!),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Danh sách ToDo (${filteredTodos.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final todo = filteredTodos[index];
                  return ListTile(
                    title: Text(todo.todoTitle ?? '[Không có nội dung]'),
                    subtitle: Text(todo.date != null
                        ? DateFormat('dd/MM/yyyy').format(todo.date!)
                        : '[Không có ngày]'),
                    trailing: Icon(
                      todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: todo.isDone ? Colors.green : Colors.grey,
                    ),
                  );
                },
                childCount: filteredTodos.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}