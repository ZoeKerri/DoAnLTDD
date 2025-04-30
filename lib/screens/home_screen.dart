import 'package:flutter/material.dart';
import 'todo_screen.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Hoang Phu Test'),
        backgroundColor: Colors.white,
        elevation: 4, // Tạo bóng đổ cho app bar
        actions: [
          Container( // Custom styling cho nút notification
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.shade800, // Viền đậm màu
                width: 2,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () => print('Đã chọn thông báo'),
              splashRadius: 20, // Kiểm soát kích thước hiệu ứng nhấn
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
      body: DashboardLayout( // Sử dụng layout component tùy chỉnh
        createSchedule: MenuCard(
          title: 'Tạo lịch',
          color: Colors.blue[200]!, // Màu pastel
          onTap: () {
            // Navigation đến màn hình TodoScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TodoScreen()),
            );
          },
        ),
        history: MenuCard(
          title: 'Lịch sử',
          color: Colors.green[200]!,
          onTap: () => print('Đã chọn lịch sử'),
        ),
        statistics: MenuCard(
          title: 'Thống kê',
          color: Colors.orange[200]!,
          onTap: () => print('Đã chọn thống kê'),
        ),
        donate: MenuCard(
          title: 'Đóng góp',
          color: Colors.purple[200]!,
          onTap: () => print('Đã chọn đóng góp'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar( // Thanh điều hướng chính
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}