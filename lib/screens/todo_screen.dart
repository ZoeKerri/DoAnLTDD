import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../components/todo_items.dart';

class TodoScreen extends StatefulWidget {
  TodoScreen({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<TodoScreen> {
  List<ToDo> todoList = ToDo.ToDoList();
  List<ToDo> _foundToDoLlist = [];

  @override
  void initState(){
    _foundToDoLlist = todoList;
    super.initState();
  }

  void _deleteToDoItem(String id) {
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
      .where((item) => item.ToDoText!
      .toLowerCase()
      .contains(enteredKey.toLowerCase())
      ).toList();
    }

    setState(() {
      _foundToDoLlist = results;
    });
  }

  void _showBottomSheet(ToDo ?t) {
      TextEditingController _textController = TextEditingController(text: t?.ToDoText ?? "");
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
                        RadioListTile(//demo radio check
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
                        Switch(//demo switch
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
                            DateTime? pickedDate = await showDatePicker(//demo datepicker
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
                            TimeOfDay? pickedTime = await showTimePicker(//demo TimePicker
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
                          onPressed: () {
                            Navigator.of(context).pop();

                            if(t != null)
                            {
                              t.ToDoText = _textController.text;
                              t.priority = _selectedRadio;
                              t.isNotify = _switchValue;
                              t.date = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                            );
                            }
                            else{
                              String toDoID = getID();
                            String toDoText = _textController.text;
                            int priority = _selectedRadio; 
                            bool notificationEnabled = _switchValue;
                            DateTime selectedDateTime = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              _selectedTime.hour,
                              _selectedTime.minute,
                            );

                            ToDo newToDo = ToDo(
                              id: toDoID,
                              ToDoText: toDoText,
                              priority: priority,
                              isNotify: notificationEnabled,
                              date: selectedDateTime,
                            );

                            _addToDo(newToDo);
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


  void _addToDo(ToDo t) {
    setState(() {
      todoList.add(t);
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
        for (ToDo t in _foundToDoLlist) TodoItems(todo: t, onDelete: _deleteToDoItem, onClick: _showBottomSheet ),
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
      if (todoList.isNotEmpty) {
        ToDo t = todoList.last;
        int numID = int.parse(t.id ?? "-1") + 1;
        return numID.toString();
      }
      return "1"; // Trả về chuỗi rỗng nếu danh sách rỗng
    }

    
}