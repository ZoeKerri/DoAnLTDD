import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../screens/manage_members_screen.dart';

class TodoItems extends StatefulWidget {
  ToDo todo;
  final String currentUserId;
  final Function(String) onDelete;
  final Function(ToDo) onClick;

  TodoItems({
    Key? key,
    required this.todo,
    required this.currentUserId,
    required this.onDelete,
    required this.onClick
  }) : super(key: key);

  @override
  _TodoItemsState createState() => _TodoItemsState();
}

class _TodoItemsState extends State<TodoItems> {

void _showDialog(bool status) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // column chỉ chiếm diện tích đủ để hiển thị
            children: [
              Text(
                "Thông báo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                status ? "Bạn đã hoàn thành công việc!" : "Bạn đã bỏ chọn công việc!",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  int getRemainingDays(DateTime targetDate)
  {
    DateTime now = DateTime.now();
    return (targetDate.difference(now).inDays) < 0 ? 0 : targetDate.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.todo.collaborators?[widget.currentUserId] ?? '';
    final isViewer = role == 'viewer';
    final isOwner = role == 'owner';
    final canEdit = role == 'owner' || role == 'editor';
    final canDelete = role == 'owner';

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          widget.onClick(widget.todo);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        tileColor: const Color.fromARGB(255, 216, 216, 216),
        leading: Checkbox(
          value: widget.todo.isDone,
          onChanged: (bool? newValue) {
            setState(() {
              widget.todo.isDone = newValue ?? false;
            });
            _showDialog(widget.todo.isDone);
          },
        ),
        title: 
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(widget.todo.todoTitle ?? "", style: TextStyle(fontSize: 16, color: Colors.black,
              decoration: widget.todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,),
              ),
             Text(
              "Còn ${getRemainingDays(widget.todo.date ?? DateTime.now())} ngày",
              style: TextStyle(fontSize: 7, color: Colors.grey[700]),
            ),
            Text(
              "Role: $role",
              style: TextStyle(fontSize: 10, color: Colors.blueGrey),
            ),
          ],
        ),
         
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.black87),
                onPressed: () {
                  widget.onClick(widget.todo);
                },
              ),
            if (canDelete)
              SizedBox(
                height: 35,
                width: 35,
                child: FilledButton(
                  onPressed: () {
                    _showDeleteConfirmation();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(Icons.delete, size: 18, color: Colors.white),
                ),
              ),
            if (isOwner)
              IconButton(
                icon: Icon(Icons.group, color: Colors.blueAccent),
                tooltip: 'Quản lý thành viên',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ManageMembersScreen(
                        todo: widget.todo,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

 void _showDeleteConfirmation() {
    showDialog(
      context: context, // Context giúp Flutter biết hiển thị dialog trên màn hình nào
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa?"),
          content: Text("Bạn có chắc chắn muốn xóa công việc này không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete(widget.todo.id ?? ""); 
                Navigator.of(context).pop(); // Đóng dialog sau khi xóa
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Xóa"),
            ),
          ],
        );
      },
    );
  }
}