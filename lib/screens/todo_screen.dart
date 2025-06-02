import 'package:doanltdd/database/firebase_db_service.dart';
import 'package:doanltdd/service/notification.dart';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../components/todo_items.dart';
import '../database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  TodoScreen({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<TodoScreen> {
  List<ToDo> todoList = [];
  List<ToDo> _foundToDoLlist = [];

  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeToDoList();
  }

  void _initializeToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('currentUserId') ?? '';
    print("=== [DEBUG] currentUserId (in _initializeToDoList) = $_currentUserId ===");

    await FirebaseDBService().syncToDoFromFirebase(_currentUserId);
    List<ToDo> data = await DatabaseHelper.instance.getAllToDos();
    print("=== [DEBUG] getAllToDos returned ${data.length} items ===");
    for (var t in data) {
      print("→ ToDo(id=${t.id}, title=${t.todoTitle}, collabs=${t.collaborators})");
    }
    data = data.where((t) => t.collaborators?.containsKey(_currentUserId) ?? false).toList();

    setState(() {
      todoList = data;
      _foundToDoLlist = data;
    });
  }


  void _deleteToDoItem(String id) async {
    final int notiId = int.parse(id).remainder(0x7FFFFFFF);
    await NotificationService.cancelNotification(notiId);
    await DatabaseHelper.instance.deleteToDo(id); 
    setState(() {
      todoList.removeWhere((item) => item.id == id); 
    });
  }


  void _searching(String enteredKey)
  {
    List <ToDo> results = [];
    if(enteredKey.isEmpty)
    {
      results = todoList;
    }
    else{
      results = todoList
      .where((item) => item.todoTitle!
      .toLowerCase()
      .contains(enteredKey.toLowerCase())
      ).toList();
    }

    setState(() {
      _foundToDoLlist = results;
    });
  }

void _showBottomSheet(ToDo? t) {
  TextEditingController _textController = TextEditingController(text: t?.todoTitle ?? "");
  int _selectedRadio = t?.priority ?? 1;
  bool _switchValue = t?.isNotify ?? false;
  DateTime _selectedDate = t?.date ?? DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(
    hour: _selectedDate.hour,
    minute: _selectedDate.minute,
  );

  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: "Nhập văn bản..."),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      RadioListTile(
                        title: Text("Quan trọng"),
                        value: 1,
                        groupValue: _selectedRadio,
                        onChanged: (int? value) {
                          setState(() => _selectedRadio = value ?? 1);
                        },
                      ),
                      RadioListTile(
                        title: Text("Bình thường"),
                        value: 2,
                        groupValue: _selectedRadio,
                        onChanged: (int? value) {
                          setState(() => _selectedRadio = value ?? 1);
                        },
                      ),
                      RadioListTile(
                        title: Text("Không quan trọng"),
                        value: 3,
                        groupValue: _selectedRadio,
                        onChanged: (int? value) {
                          setState(() => _selectedRadio = value ?? 1);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Bật/Tắt thông báo"),
                      Switch(
                        value: _switchValue,
                        onChanged: (bool value) {
                          setState(() => _switchValue = value);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() => _selectedDate = pickedDate);
                          }
                        },
                        child: Text("Chọn ngày"),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Giờ: ${_selectedTime.hour}:${_selectedTime.minute}"),
                      ElevatedButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (pickedTime != null) {
                            setState(() => _selectedTime = pickedTime);
                          }
                        },
                        child: Text("Chọn giờ"),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Hủy"),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();

                          DateTime selectedDateTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          );
                          ToDo todo;
                          if (t != null) {
                            // Cập nhật dữ liệu
                            t.todoTitle = _textController.text;
                            t.priority = _selectedRadio;
                            t.isNotify = _switchValue;
                            t.date = selectedDateTime;

                            _updateToDo(t);
                            todo = t;
                          } else {
                            String toDoID = getID();
                            ToDo newToDo = ToDo(
                              id: toDoID,
                              todoTitle: _textController.text,
                              priority: _selectedRadio,
                              isNotify: _switchValue,
                              date: selectedDateTime,
                              collaborators: { _currentUserId: 'owner' },
                            );

                            _addToDo(newToDo);
            
                            todo = newToDo;
                          }

                          final allTodos = await DatabaseHelper.instance.getAllToDos();
                          for (var item in allTodos) {
                            print("→ ToDo(id=${item.id}, title=${item.todoTitle}, collaborators=${item.collaborators})");
                          }
                          
                          final int notiId = int.parse(todo.id!).remainder(0x7FFFFFFF);
                          final tz.TZDateTime scheduledDate = tz.TZDateTime.from(selectedDateTime, tz.local);
                          final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
                          if (_switchValue && selectedDateTime.isAfter(now)) {
                            await NotificationService.scheduleNotification(
                              id: notiId,
                              title: 'Nhắc: ${todo.todoTitle}',
                              body: 'Hạn: ${DateFormat.yMd().add_Hm().format(scheduledDate)}',
                              scheduledDate: scheduledDate,
                            );
                          } else {
                            await NotificationService.cancelNotification(notiId);
                          }
                        },
                        child: Text(t != null ? "Lưu" : "OK"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  void _addToDo(ToDo t) async {
    await DatabaseHelper.instance.insertToDo(t); 
    await FirebaseDBService().syncToDoToFirebase();
    setState(() {
      todoList.add(t); 
      _foundToDoLlist.add(t);
    });
  }
  
  void _updateToDo(ToDo t) async {
    await DatabaseHelper.instance.updateToDo(t);
    
    setState(() {
      int index = todoList.indexWhere((todo) => todo.id == t.id);
      if (index != -1) {
        todoList[index] = t;
      }
      int foundIndex =
          _foundToDoLlist.indexWhere((todo) => todo.id == t.id);
      if (foundIndex != -1) {
        _foundToDoLlist[foundIndex] = t;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _searchBox(),
          Expanded(child: _todoListView()),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 35,
        height: 35,
        child: FloatingActionButton(
          onPressed: () {
            _showBottomSheet(null);
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => _searching(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          prefixIcon: Icon(Icons.search, color: Colors.black, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Color.fromARGB(255, 212, 209, 209),
          hintText: 'Tìm kiếm',
        ),
      ),
    );
  }

  Widget _todoListView() {
    return ListView(
      padding: EdgeInsets.all(15),
      children: [
        Text(
          'Danh sách ToDo',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 20),
        for (ToDo t in _foundToDoLlist)
          TodoItems(
            todo: t,
            currentUserId: _currentUserId,
            onDelete: _deleteToDoItem,
            onClick: _showBottomSheet,
          ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Color.fromARGB(255, 0, 195, 255),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Tạo ToDo List",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Hello\n",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  TextSpan(
                    text: "Hoang Phu Test".substring(0, 5) + "...",
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    }
    String getID() {
      return DateTime.now().millisecondsSinceEpoch.toString().toString();
    }

    
}