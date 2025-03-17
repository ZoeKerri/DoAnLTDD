// Import thư viện Flutter Material và màn hình chính
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/TaskOverviewScreen.dart';

// Điểm bắt đầu của ứng dụng - chạy widget gốc MyApp
void main() => runApp(MyApp());

// Lớp chính quản lý cấu trúc ứng dụng
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner debug góc phải
      home: TaskOverviewScreen(), // Set HomeScreen làm màn hình đầu tiên
    );
  }
}