import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

// Định nghĩa một callback cho việc hoàn thành (lưu/cập nhật) ToDo
typedef OnSaveToDo = Future<void> Function(ToDo todo, bool shouldScheduleNotification);

class ToDoFormBottomSheet extends StatefulWidget {
  final ToDo initialTodo; 
  final bool isViewer;
  final String currentUserId; 
  final OnSaveToDo onSaveToDo;

  const ToDoFormBottomSheet({
    super.key,
    required this.initialTodo,
    required this.isViewer,
    required this.currentUserId, 
    required this.onSaveToDo,
  });

  @override
  State<ToDoFormBottomSheet> createState() => _ToDoFormBottomSheetState();
}

class _ToDoFormBottomSheetState extends State<ToDoFormBottomSheet> {
  late TextEditingController _textController;
  late int _selectedRadio;
  late bool _switchValue;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các giá trị từ initialTodo
    _textController = TextEditingController(text: widget.initialTodo.todoTitle);
    _selectedRadio = widget.initialTodo.priority ?? 3; // Mặc định là 3 (Không quan trọng)
    _switchValue = widget.initialTodo.isNotify ?? false; // Mặc định không thông báo
    _selectedDate = widget.initialTodo.date ?? DateTime.now();
    _selectedTime = widget.initialTodo.date != null
        ? TimeOfDay.fromDateTime(widget.initialTodo.date!)
        : TimeOfDay.now();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 32, // Đảm bảo bàn phím không che mất nội dung
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: "Nhập văn bản...",
              border: OutlineInputBorder(),
            ),
            enabled: !widget.isViewer,
            maxLines: null,
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              RadioListTile(
                title: const Text("Quan trọng"),
                value: 1,
                groupValue: _selectedRadio,
                onChanged: widget.isViewer
                    ? null
                    : (int? value) {
                        setState(() => _selectedRadio = value ?? 1);
                      },
              ),
              RadioListTile(
                title: const Text("Bình thường"),
                value: 2,
                groupValue: _selectedRadio,
                onChanged: widget.isViewer
                    ? null
                    : (int? value) {
                        setState(() => _selectedRadio = value ?? 2);
                      },
              ),
              RadioListTile(
                title: const Text("Không quan trọng"),
                value: 3,
                groupValue: _selectedRadio,
                onChanged: widget.isViewer
                    ? null
                    : (int? value) {
                        setState(() => _selectedRadio = value ?? 3);
                      },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bật/Tắt thông báo"),
              Switch(
                value: _switchValue,
                onChanged: widget.isViewer
                    ? null
                    : (bool value) {
                        setState(() => _switchValue = value);
                      },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}"),
              ElevatedButton(
                onPressed: widget.isViewer
                    ? null
                    : () async {
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
                child: const Text("Chọn ngày"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Giờ: ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}"),
              ElevatedButton(
                onPressed: widget.isViewer
                    ? null
                    : () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (pickedTime != null) {
                          setState(() => _selectedTime = pickedTime);
                        }
                      },
                child: const Text("Chọn giờ"),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Hủy"),
              ),
              const SizedBox(width: 8),
              // Nút lưu chỉ hiển thị nếu không ở chế độ chỉ xem
              if (!widget.isViewer)
                ElevatedButton(
                  onPressed: () async {
                    // Kết hợp ngày và giờ đã chọn
                    DateTime selectedDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );

                    // Cập nhật ToDo hiện có
                    ToDo updatedToDo = widget.initialTodo.copyWith(
                      todoTitle: _textController.text,
                      priority: _selectedRadio,
                      isNotify: _switchValue,
                      date: selectedDateTime,
                      updatedAt: DateTime.now(),
                      isSynced: false,
                    );

                    // Gọi callback để cập nhật ToDo
                    await widget.onSaveToDo(updatedToDo, _switchValue);
                    Navigator.of(context).pop(); // Đóng bottom sheet sau khi lưu
                  },
                  child: const Text("Lưu"), // Luôn là "Lưu"
                ),
            ],
          ),
        ],
      ),
    );
  }
}