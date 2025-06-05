import 'package:flutter/material.dart';
import '../database/firebase_db_service.dart';
import '../database/database_helper.dart';
import '../models/todo.dart';

class ManageMembersScreen extends StatefulWidget {
  final ToDo todo;
  final String currentUserId;
  const ManageMembersScreen({
    super.key,
    required this.todo,
    required this.currentUserId,
  });

  @override
  _ManageMembersScreenState createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  late Map<String, String> collabs;

  final Map<String, String> _userEmails = {};

  @override
  void initState() {
    super.initState();
    collabs = Map.from(widget.todo.collaborators ?? {});
    _loadAllUserEmails();
  }

  Future<void> _loadAllUserEmails() async {
    for (final userId in collabs.keys) {
      if (_userEmails.containsKey(userId)) continue;

      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        _userEmails[userId] = user.email;
      } else {
        _userEmails[userId] = '(Không xác định)';
      }
      if (mounted) setState(() {});
    }
  }

  void _onCollaboratorAdded(String newUserId, String newRole) async {
    setState(() {
      collabs[newUserId] = newRole;
    });

    if (!_userEmails.containsKey(newUserId)) {
      final user = await DatabaseHelper.instance.getUserById(newUserId);
      if (user != null) {
        _userEmails[newUserId] = user.email;
      } else {
        _userEmails[newUserId] = '(Không xác định)';
      }
      if (mounted) setState(() {});
    }
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
    final sortedEntries = collabs.entries.toList()
      ..sort((a, b) {
        const rank = {'owner': 0, 'editor': 1, 'viewer': 2};
        final ra = rank[a.value] ?? 99;
        final rb = rank[b.value] ?? 99;
        return ra.compareTo(rb);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý thành viên'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: sortedEntries.map((e) {
                final userId = e.key;
                final role = e.value;
                final isSelf = userId == widget.currentUserId;

                final email = _userEmails[userId] ?? '(Đang tải...)';

                return ListTile(
                  title: Text(email, style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Role: $role'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isSelf) ...[
                        DropdownButton<String>(
                          value: role,
                          items: [
                            DropdownMenuItem(
                              value: 'owner',
                              child: Text('Owner'),
                            ),
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
                _onCollaboratorAdded(newUserId, newRole);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _updateFirebase,
                child: Text('Lưu thay đổi'),
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
  const AddCollaboratorWidget({super.key, required this.onAdded});

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
            DropdownMenuItem(value: 'owner', child: Text('Owner')),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: _invite,
              child: Text('Mời cộng tác'),
            ),
          ),
        ),
      ],
    );
  }
}