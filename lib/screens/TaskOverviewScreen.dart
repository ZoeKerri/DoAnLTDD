import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class TaskOverviewScreen extends StatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  State<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends State<TaskOverviewScreen> {
  // Dữ liệu gốc: các nhóm task theo ngày
  late List<DayGroup> _originalDayGroups = [];
  // Dữ liệu hiển thị sau khi lọc cho từng nhóm (ban đầu bằng dữ liệu gốc)
  late List<DayGroup> _filteredDayGroups = [];

  // Các biến lưu tiêu chí lọc (áp dụng cho từng nhóm khi nhấn Lọc)
  int? _selectedPriorityFilter; // 1, 2, 3 hoặc null (không lọc theo mức độ)
  final TextEditingController _timeFilterController = TextEditingController();
  final TextEditingController _searchFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(); 
  }

  Future<void> _loadData() async {
    List<ToDo> defaultToDo = await DatabaseHelper.instance.getAllToDos();

    _originalDayGroups = defaultToDo
        .fold<Map<String, List<ToDo>>>({}, (grouped, todo) {
      String dayLabel = DateFormat('dd/MM/yyyy').format(todo.date ?? DateTime.now());
      grouped.putIfAbsent(dayLabel, () => []).add(todo);
      return grouped;
    })
        .entries
        .map((entry) => DayGroup(dayLabel: entry.key, todoList: entry.value))
        .toList();

    _originalDayGroups.sort((a, b) {
      DateTime dateA = DateFormat('dd/MM/yyyy').parse(a.dayLabel);
      DateTime dateB = DateFormat('dd/MM/yyyy').parse(b.dayLabel);
      return dateA.compareTo(dateB);
    });

    setState(() {
      _filteredDayGroups = _originalDayGroups
          .map((dayGroup) => DayGroup(
                dayLabel: dayGroup.dayLabel,
                todoList: List.from(dayGroup.todoList),
                isCollapsed: dayGroup.isCollapsed,
              ))
          .toList();
    });
  }


  /// Hàm trả về màu theo độ ưu tiên:
  /// 1 = Quan trọng (đỏ), 2 = Ít quan trọng hơn (vàng), 3 = Bình thường (xanh lá)
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      case 3:
      default:
        return Colors.green;
    }
  }

void _showFilterDialog(int dayIndex) {
  // Reset các tiêu chí lọc khi mở dialog mới
  _selectedPriorityFilter = null;
  _timeFilterController.clear();
  _searchFilterController.clear();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setStateDialog) {
          return AlertDialog(
            title: const Text("Bộ lọc công việc"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lọc theo mức độ:"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("Quan trọng"),
                        selected: _selectedPriorityFilter == 1,
                        selectedColor: Colors.red.withOpacity(0.5),
                        onSelected: (selected) {
                          setStateDialog(() {
                            _selectedPriorityFilter = selected ? 1 : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Ít quan trọng"),
                        selected: _selectedPriorityFilter == 2,
                        selectedColor: Colors.yellow.withOpacity(0.5),
                        onSelected: (selected) {
                          setStateDialog(() {
                            _selectedPriorityFilter = selected ? 2 : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Bình thường"),
                        selected: _selectedPriorityFilter == 3,
                        selectedColor: Colors.green.withOpacity(0.5),
                        onSelected: (selected) {
                          setStateDialog(() {
                            _selectedPriorityFilter = selected ? 3 : null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Lọc theo thời gian:"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _timeFilterController,
                    decoration: const InputDecoration(
                      labelText: "Nhập thời gian (ví dụ: 10:30)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Tìm kiếm:"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchFilterController,
                    decoration: const InputDecoration(
                      labelText: "Tìm kiếm công việc",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Reset bộ lọc cho nhóm này (trong dialog)
                  setState(() {
                    _selectedPriorityFilter = null;
                    _timeFilterController.clear();
                    _searchFilterController.clear();
                  });
                },
                child: const Text("Reset"),
              ),
              TextButton(
                onPressed: () {
                  // Áp dụng lọc cho nhóm có chỉ số dayIndex
                  setState(() {
                   List<ToDo> filteredTasks = _originalDayGroups[dayIndex].todoList.where((todo) {
                    bool matchesPriority = _selectedPriorityFilter == null ||
                        todo.priority == _selectedPriorityFilter;

                    bool matchesTime = _timeFilterController.text.isEmpty ||
                        todo.date.toString().contains(_timeFilterController.text);

                    bool matchesSearch = _searchFilterController.text.isEmpty ||
                        (todo.todoTitle ?? "").toLowerCase().contains(
                            _searchFilterController.text.toLowerCase());

                    return matchesPriority && matchesTime && matchesSearch;
                  }).toList();


                    _filteredDayGroups[dayIndex] = DayGroup(
                      dayLabel: _originalDayGroups[dayIndex].dayLabel,
                      todoList: filteredTasks,
                      isCollapsed: _filteredDayGroups[dayIndex].isCollapsed,
                    );
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Áp dụng"),
              ),
            ],
          );
        },
      );
    },
  );
}


  /// Hàm reset bộ lọc cho nhóm ngày có chỉ số [dayIndex] từ bên ngoài (nút "Hủy Lọc")
  void _resetFilter(int dayIndex) {
    setState(() {
      _filteredDayGroups[dayIndex] = DayGroup(
        dayLabel: _originalDayGroups[dayIndex].dayLabel,
        todoList: List.from(_originalDayGroups[dayIndex].todoList),
        isCollapsed: _filteredDayGroups[dayIndex].isCollapsed,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng List.generate để có chỉ số của từng nhóm ngày
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color.fromARGB(255, 0, 195, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tạo ToDo List",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Hello\n",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    TextSpan(
                      text: "Hoang Phu Test".substring(0, 5) + "...",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        // Cho phép cuộn dọc nếu có nhiều ngày
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_filteredDayGroups.length, (dayIndex) {
              DayGroup dayGroup = _filteredDayGroups[dayIndex];
              // Kiểm tra nếu bộ lọc đã được áp dụng cho nhóm này
              bool isFiltered = _filteredDayGroups[dayIndex].todoList.length <
                  _originalDayGroups[dayIndex].todoList.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header nhóm ngày: tiêu đề, nút Expand/Collapse, nút Lọc, và nếu có bộ lọc được áp dụng thì nút Hủy Lọc
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dayGroup.dayLabel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      dayGroup.isCollapsed
                          ? Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _showFilterDialog(dayIndex),
                                  child: const Text(
                                    "Lọc",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Nút Hủy Lọc chỉ xuất hiện nếu bộ lọc đã được áp dụng
                                if (isFiltered)
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _resetFilter(dayIndex),
                                        child: const Text(
                                          "Hủy Lọc",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      dayGroup.isCollapsed = !dayGroup.isCollapsed;
                                    });
                                  },
                                  child: const Text(
                                    "Collapse All",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  dayGroup.isCollapsed = !dayGroup.isCollapsed;
                                });
                              },
                              child: const Text(
                                "Expand All",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Hiển thị danh sách task:
                  // Nếu expanded: dạng dọc (hàng ngang)
                  // Nếu collapsed: dạng ngang
                  dayGroup.isCollapsed
                      ?  Column(
                          children: dayGroup.todoList.map((todo) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTaskCard(todo),
                            );
                          }).toList(),
                        ):
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: dayGroup.todoList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, todoIndex) {
                              final task = dayGroup.todoList[todoIndex];
                              return _buildTaskCard(task);
                            },
                          ),
                        )
                      ,
                  const SizedBox(height: 24),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Hàm tạo card task với viền màu bên trái (theo status) và bên phải (theo priority) + bo tròn
  Widget _buildTaskCard(ToDo todo) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Chỉ 1 thanh màu thôi dùng để chỉ độ ưu tiên của todo
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: getPriorityColor(todo.priority ?? 0),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
            // Nội dung chính
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.todoTitle ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: getPriorityColor(todo.priority ?? 0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            todo.isDone ? "Pending" : "Complete",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          todo.date != null 
                          ? DateFormat('HH:mm').format(todo.date!) 
                          : DateFormat('HH:mm').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3, //CHỨC NĂNG COOP SẼ ĐƯỢC THÊM SAU NÊN HIỆN TẠI CHỈ ĐỂ 3 CÁI AVATAR TRỐNG
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final avatarText = "A";
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: getPriorityColor(todo.priority ?? 0),
                            child: Text(
                              avatarText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model nhóm task theo ngày
class DayGroup {
  final String dayLabel;
  final List<ToDo> todoList;
  bool isCollapsed = true; // true: hiển thị theo carousel (hàng ngang), false: hiển thị dọc

  DayGroup({
    required this.dayLabel,
    required this.todoList,
    this.isCollapsed = false,
  });
}

 