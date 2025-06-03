import 'package:doanltdd/database/firebase_db_service.dart';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doanltdd/widgets/todo_form_bottom_sheet.dart'; 
import 'package:doanltdd/service/notification.dart'; 
import 'package:timezone/timezone.dart' as tz; 
import '../screens/manage_members_screen.dart';

class TaskOverviewScreen extends StatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  State<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends State<TaskOverviewScreen> {
  late List<DayGroup> _originalDayGroups = [];
  late List<DayGroup> _filteredDayGroups = [];
  String _currentUsername = "";
  String _currentUserId = ""; 
  bool isLate = false;

  // Các biến lưu tiêu chí lọc (áp dụng cho từng nhóm khi nhấn Lọc)
  int? _selectedPriorityFilter; // 1, 2, 3 hoặc null (không lọc theo mức độ)
  bool? _selectedCompletionFilter; 
  final TextEditingController _timeFilterController = TextEditingController();
  final TextEditingController _searchFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Gọi DatabaseHelper.instance.getAllToDos() để kích hoạt tự động cập nhật ToDo quá hạn
    List<ToDo> allToDos = await DatabaseHelper.instance.getAllToDos();
    final prefs = await SharedPreferences.getInstance();

    _originalDayGroups = allToDos
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
    _currentUsername = prefs.getString('currentUsername') ?? '';
    _currentUserId = prefs.getString('currentUserId') ?? ''; 
  }

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

  Color getAvatarColor(String text) {
    if (text.isEmpty) return Colors.grey;
    final int hash = text.hashCode;
    final List<Color> colors = [
      Colors.red.shade200, Colors.blue.shade200, Colors.green.shade200,
      Colors.orange.shade200, Colors.purple.shade200, Colors.teal.shade200,
      Colors.brown.shade200, Colors.cyan.shade200, Colors.indigo.shade200,
    ];
    return colors[hash % colors.length];
  }

  // Hàm xử lý việc cập nhật ToDo từ bottom sheet hoặc từ các nút trong card
  Future<void> _handleSaveToDo(ToDo todo, bool shouldScheduleNotification) async {
    await DatabaseHelper.instance.updateToDo(todo); 
    // Logic quản lý thông báo (giống TodoScreen)
    final int notiId = int.parse(todo.id!).remainder(0x7FFFFFFF);
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(todo.date!, tz.local);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    if (shouldScheduleNotification && todo.isNotify! && todo.date != null && todo.date!.isAfter(now)) {
      await NotificationService.scheduleNotification(
        id: notiId,
        title: 'Nhắc: ${todo.todoTitle}',
        body: 'Hạn: ${DateFormat.yMd().add_Hm().format(scheduledDate)}',
        scheduledDate: scheduledDate,
      );
    } else {
      await NotificationService.cancelNotification(notiId);
    }
    setState(() {
      isLate = true;
    });
    await _loadData(); 
  }

  // Hàm để hiển thị bottom sheet chỉnh sửa ToDo (sẽ được gọi khi click vào card hoặc nút Group)
  void _showEditToDoBottomSheet(ToDo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        // Kiểm tra quyền chỉnh sửa
        bool canEdit = (todo.collaborators?[_currentUserId] == 'owner' || todo.collaborators?[_currentUserId] == 'editor') && !todo.isDone;

        return ToDoFormBottomSheet(
          initialTodo: todo,
          isViewer: !canEdit, // Nếu không thể chỉnh sửa, hiển thị ở chế độ xem
          currentUserId: _currentUserId,
          onSaveToDo: _handleSaveToDo, // Truyền hàm save
        );
      },
    );
  }

  // Hàm xóa ToDo (sẽ được gọi từ nút xóa)
  Future<void> _deleteToDo(String todoId, String todoTitle) async {
    final int notiId = int.parse(todoId).remainder(0x7FFFFFFF);
    await NotificationService.cancelNotification(notiId);
    await DatabaseHelper.instance.deleteToDo(todoId);
    await FirebaseDBService().deleteTodo(todoId);
    await _loadData(); // Tải lại dữ liệu để cập nhật UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa công việc "$todoTitle"')),
    );
  }

  void _showFilterDialog(int dayIndex) {
    // Reset các tiêu chí lọc khi mở dialog mới
    _selectedPriorityFilter = null;
    _selectedCompletionFilter = null; // Reset bộ lọc trạng thái
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
                    const Text("Lọc theo trạng thái:"),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("Hoàn thành"),
                          selected: _selectedCompletionFilter == true,
                          selectedColor: Colors.blue.withOpacity(0.5),
                          onSelected: (selected) {
                            setStateDialog(() {
                              _selectedCompletionFilter = selected ? true : null;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text("Chưa hoàn thành"),
                          selected: _selectedCompletionFilter == false,
                          selectedColor: Colors.orange.withOpacity(0.5),
                          onSelected: (selected) {
                            setStateDialog(() {
                              _selectedCompletionFilter = selected ? false : null;
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
                    // Reset bộ lọc cho dialog
                    setStateDialog(() {
                      _selectedPriorityFilter = null;
                      _selectedCompletionFilter = null;
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

                        bool matchesCompletion = _selectedCompletionFilter == null ||
                            todo.isDone == _selectedCompletionFilter; 

                        // Chú ý: Cần xử lý parsing thời gian chính xác hơn nếu muốn so sánh
                        // Ví dụ: tách giờ và phút từ todo.date và so sánh với _timeFilterController.text
                        bool matchesTime = _timeFilterController.text.isEmpty ||
                            (todo.date != null && DateFormat('HH:mm').format(todo.date!) == _timeFilterController.text);


                        bool matchesSearch = _searchFilterController.text.isEmpty ||
                            (todo.todoTitle ?? "").toLowerCase().contains(
                                _searchFilterController.text.toLowerCase());

                        return matchesPriority && matchesCompletion && matchesTime && matchesSearch;
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold, // Chữ "Hello" in đậm
                      ),
                    ),
                    TextSpan(
                      text: (_currentUsername.length > 5 ? _currentUsername.substring(0, 5) + '...' : _currentUsername),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal, // Tên người dùng chữ thường
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_filteredDayGroups.length, (dayIndex) {
              DayGroup dayGroup = _filteredDayGroups[dayIndex];
              bool isFiltered = _filteredDayGroups[dayIndex].todoList.length <
                  _originalDayGroups[dayIndex].todoList.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  dayGroup.isCollapsed
                      ? Column(
                          children: dayGroup.todoList.map((todo) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTaskCard(todo),
                            );
                          }).toList(),
                        )
                      : SizedBox(
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

  Widget _buildTaskCard(ToDo todo) {
    // Xác định vai trò của người dùng hiện tại
    final String currentUserRole = todo.collaborators?[_currentUserId] ?? '';
    
    // Quyền chỉnh sửa/xóa: owner hoặc editor. Viewer KHÔNG thể chỉnh sửa/xóa.
    bool canEdit = (currentUserRole == 'owner' || currentUserRole == 'editor'); // Để mở form chỉnh sửa
    bool canDelete = (currentUserRole == 'owner'); // Chỉ owner mới được xóa

    return InkWell(
      onTap: () {
        // Khi click vào card, mở bottom sheet chỉnh sửa.
        // Quyền chỉnh sửa trong bottom sheet sẽ được xử lý bên trong _showEditToDoBottomSheet.
        _showEditToDoBottomSheet(todo); 
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.todoTitle ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // Thêm gạch ngang nếu đã hoàn thành
                          decoration: todo.isDone! ? TextDecoration.lineThrough : TextDecoration.none,
                          color: todo.isDone! ? Colors.grey : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: todo.isDone! ? Colors.lightGreen : Colors.orange, // Màu dựa trên trạng thái hoàn thành
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              todo.isDone! ? "Hoàn thành" : "Đang chờ",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white, // Đổi màu chữ cho dễ nhìn
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            todo.date != null
                                ? DateFormat('HH:mm').format(todo.date!)
                                : 'N/A', // Hiển thị 'N/A' nếu ngày là null
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Phần chứa các avatar người cộng tác
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: todo.collaborators?.length ?? 0,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final collaboratorEntries = todo.collaborators?.entries.toList();

                            if (collaboratorEntries == null || index >= collaboratorEntries.length) {
                              return const SizedBox.shrink();
                            }

                            final collaboratorName = collaboratorEntries[index].value;
            
                            final avatarText = collaboratorName.isNotEmpty ? collaboratorName[0].toUpperCase() : '!';

                            return CircleAvatar(
                              radius: 20,
                              backgroundColor: getAvatarColor(collaboratorName),
                              child: Text(
                                avatarText,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8), // Thêm khoảng cách trước các nút
                      // Hàng chứa ba nút mới
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end, 
                        children: [
                          if (canEdit)
                            IconButton(
                              icon: Icon(
                                todo.isDone! ? Icons.check_box : Icons.check_box_outline_blank,
                                color: todo.isDone! ? Colors.green : Colors.black,
                              ),
                              onPressed: () {
                               final updatedTodo = todo.copyWith(isDone: !todo.isDone!);
                                  _handleSaveToDo(updatedTodo, updatedTodo.isNotify!);
                                  if(!isLate){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Chỉnh sửa thành công')));
                                  }
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã quá hạn không thể chỉnh sửa!')));
                                  }
                                   
                              },
                            ),
                          const SizedBox(width: 8),

                          if (canEdit) // Chỉ owner hoặc editor mới được quản lý nhóm
                            IconButton(
                              icon: const Icon(Icons.group, color: Colors.blue), 
                              onPressed: () {
                               Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ManageMembersScreen(
                                      todo: todo,
                                      currentUserId: _currentUserId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(width: 8),
                          
                          // NÚT DELETE
                          if (canDelete) // Chỉ owner mới được xóa
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteToDo(todo.id!, todo.todoTitle!); // Gọi hàm xóa
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Model nhóm task theo ngày
class DayGroup {
  final String dayLabel;
  final List<ToDo> todoList;
  bool isCollapsed; // true: hiển thị theo carousel (hàng ngang), false: hiển thị dọc

  DayGroup({
    required this.dayLabel,
    required this.todoList,
    this.isCollapsed = false, // Mặc định là expanded (dọc)
  });
}