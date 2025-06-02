import 'package:flutter/material.dart';
import '../database/firebase_db_service.dart';
import '../database/database_helper.dart';
import '../models/todo.dart';

class ManageMembersScreen extends StatefulWidget {
  final ToDo todo;
  final String currentUserId;
  const ManageMembersScreen({
    Key? key,
    required this.todo,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ManageMembersScreenState createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  late Map<String, String> collabs;

  @override
  void initState() {
    super.initState();
    collabs = Map.from(widget.todo.collaborators ?? {});
  }

  void _updateFirebase() async {
    await FirebaseDBService().update(
      path: "todos/${widget.todo.id}",
      data: {'collaborators': collabs},
    );

    final updatedToDo = widget.todo.copyWith(
      collaborators: collabs,
      isSynced: false,
      updatedAt: DateTime.now(),
    );
    await DatabaseHelper.instance.updateToDo(updatedToDo);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý thành viên'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: collabs.entries.map((e) {
                final userId = e.key;
                final role = e.value;
                return ListTile(
                  title: Text('User ID: $userId'),
                  subtitle: Text('Role: $role'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (userId != widget.currentUserId) ...[
                        DropdownButton<String>(
                          value: role,
                          items: [
                            DropdownMenuItem(
                              value: 'editor',
                              child: Text('Editor'),
                            ),
                            DropdownMenuItem(
                              value: 'viewer',
                              child: Text('Viewer'),
                            ),
                          ],
                          onChanged: (newRole) {
                            if (newRole == null) return;
                            setState(() {
                              collabs[userId] = newRole;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              collabs.remove(userId);
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          Divider(thickness: 1),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AddCollaboratorWidget(
              onAdded: (newUserId, newRole) {
                setState(() {
                  collabs[newUserId] = newRole;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: _updateFirebase,
              child: Text('Lưu thay đổi'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddCollaboratorWidget extends StatefulWidget {
  final Function(String userId, String role) onAdded;
  const AddCollaboratorWidget({Key? key, required this.onAdded})
      : super(key: key);

  @override
  _AddCollaboratorWidgetState createState() => _AddCollaboratorWidgetState();
}

class _AddCollaboratorWidgetState extends State<AddCollaboratorWidget> {
  final _emailController = TextEditingController();
  String _selectedRole = 'viewer';

  void _invite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final user = await DatabaseHelper.instance.getUserByEmail(email);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy user với email $email')),
      );
      return;
    }
    widget.onAdded(user.id.toString(), _selectedRole);

    _emailController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã mời ${user.name} với quyền $_selectedRole')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email người được mời',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8),
        DropdownButton<String>(
          value: _selectedRole,
          items: [
            DropdownMenuItem(value: 'editor', child: Text('Editor')),
            DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
          ],
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _selectedRole = val;
            });
          },
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _invite,
          child: Text('Mời cộng tác'),
        ),
      ],
    );
  }
}