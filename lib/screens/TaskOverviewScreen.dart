import 'package:flutter/material.dart';

class TaskOverviewScreen extends StatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  State<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends State<TaskOverviewScreen> {
  // Dữ liệu gốc: các nhóm task theo ngày
  late List<DayGroup> _originalDayGroups;
  // Dữ liệu hiển thị sau khi lọc cho từng nhóm (ban đầu bằng dữ liệu gốc)
  late List<DayGroup> _filteredDayGroups;

  // Các biến lưu tiêu chí lọc (áp dụng cho từng nhóm khi nhấn Lọc)
  int? _selectedPriorityFilter; // 1, 2, 3 hoặc null (không lọc theo mức độ)
  final TextEditingController _timeFilterController = TextEditingController();
  final TextEditingController _searchFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _originalDayGroups = [
      DayGroup(
        dayLabel: "Hôm nay",
        tasks: [
          Task(
            title: "Daily Scrum Meeting",
            statusLabel: "IN REVIEW",
            statusColor: Colors.orange[300],
            shortLabel: "R",
            shortLabelColor: Colors.blue,
            dateTimeText: "10:30",
            userAvatars: ["S", "J", "D"],
            priority: 1,
          ),
          Task(
            title: "Project Standup",
            statusLabel: "COMPLETED",
            statusColor: Colors.green[300],
            shortLabel: "C",
            shortLabelColor: Colors.green,
            dateTimeText: "11:00",
            userAvatars: ["M", "A"],
            priority: 3,
          ),
          Task(
            title: "Review Docs",
            statusLabel: "PENDING",
            statusColor: Colors.yellow[300],
            shortLabel: "P",
            shortLabelColor: Colors.orange,
            dateTimeText: "13:00",
            userAvatars: ["X", "Y"],
            priority: 2,
          ),
        ],
      ),
      DayGroup(
        dayLabel: "Ngày mai",
        tasks: [
          Task(
            title: "Design Review",
            statusLabel: "IN PROGRESS",
            statusColor: Colors.purple[200],
            shortLabel: "P",
            shortLabelColor: Colors.red,
            dateTimeText: "17:00",
            userAvatars: ["L", "T", "E"],
            priority: 2,
          ),
          Task(
            title: "Client Meeting",
            statusLabel: "PENDING",
            statusColor: Colors.yellow[300],
            shortLabel: "P",
            shortLabelColor: Colors.orange,
            dateTimeText: "15:00",
            userAvatars: ["K", "R"],
            priority: 3,
          ),
        ],
      ),
    ];
    // Ban đầu không lọc, _filteredDayGroups là bản sao của _originalDayGroups
    _filteredDayGroups = _originalDayGroups
        .map((dayGroup) => DayGroup(
              dayLabel: dayGroup.dayLabel,
              tasks: List.from(dayGroup.tasks),
              isExpanded: dayGroup.isExpanded,
            ))
        .toList();
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
                    List<Task> filteredTasks = _originalDayGroups[dayIndex].tasks.where((task) {
                      bool matchesPriority = _selectedPriorityFilter == null ||
                          task.priority == _selectedPriorityFilter;
                      bool matchesTime = _timeFilterController.text.isEmpty ||
                          task.dateTimeText.contains(_timeFilterController.text);
                      bool matchesSearch = _searchFilterController.text.isEmpty ||
                          task.title.toLowerCase().contains(
                              _searchFilterController.text.toLowerCase());
                      return matchesPriority && matchesTime && matchesSearch;
                    }).toList();

                    _filteredDayGroups[dayIndex] = DayGroup(
                      dayLabel: _originalDayGroups[dayIndex].dayLabel,
                      tasks: filteredTasks,
                      isExpanded: _filteredDayGroups[dayIndex].isExpanded,
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
        tasks: List.from(_originalDayGroups[dayIndex].tasks),
        isExpanded: _filteredDayGroups[dayIndex].isExpanded,
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
              bool isFiltered = _filteredDayGroups[dayIndex].tasks.length <
                  _originalDayGroups[dayIndex].tasks.length;
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
                      dayGroup.isExpanded
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
                                      dayGroup.isExpanded = !dayGroup.isExpanded;
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
                                  dayGroup.isExpanded = !dayGroup.isExpanded;
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
                  // Nếu expanded: dạng carousel (hàng ngang)
                  // Nếu collapsed: dạng danh sách dọc
                  dayGroup.isExpanded
                      ? SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: dayGroup.tasks.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, taskIndex) {
                              final task = dayGroup.tasks[taskIndex];
                              return _buildTaskCard(task);
                            },
                          ),
                        )
                      : Column(
                          children: dayGroup.tasks.map((task) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTaskCard(task),
                            );
                          }).toList(),
                        ),
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
  Widget _buildTaskCard(Task task) {
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
            // Thanh màu bên trái (status)
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: task.statusColor ?? Colors.grey,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
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
                      task.title,
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
                            color: task.statusColor ?? Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.statusLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: task.shortLabelColor ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            task.shortLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          task.dateTimeText,
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
                        itemCount: task.userAvatars.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final avatarText = task.userAvatars[index];
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: getPriorityColor(task.priority),
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
            // Thanh màu bên phải (priority)
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: getPriorityColor(task.priority),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
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
  final List<Task> tasks;
  bool isExpanded; // true: hiển thị theo carousel (hàng ngang), false: hiển thị dọc

  DayGroup({
    required this.dayLabel,
    required this.tasks,
    this.isExpanded = false,
  });
}

/// Model dữ liệu cho từng task
class Task {
  final String title;
  final String statusLabel;
  final Color? statusColor;
  final String shortLabel;
  final Color? shortLabelColor;
  final String dateTimeText;
  final List<String> userAvatars;
  final int priority; // 1 = Quan trọng (đỏ), 2 = Ít quan trọng, 3 = Bình thường

  Task({
    required this.title,
    required this.statusLabel,
    this.statusColor,
    required this.shortLabel,
    this.shortLabelColor,
    required this.dateTimeText,
    required this.userAvatars,
    required this.priority,
  });
}
