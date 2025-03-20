// Import thư viện Flutter Material và màn hình chính
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/TaskOverviewScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';//firebase thì chịu tạm thời chưa up realtime được 


//LƯU Ý PHẢI CHẠY TRÊN GIẢ LẬP ANDROID CHỨ CHẠY TRÊN WEB NÓ K LOAD ĐƯỢC SQLITE

// Điểm bắt đầu của ứng dụng - chạy widget gốc MyApp
void main() async{
  runApp(MyApp());
} 


// Lớp chính quản lý cấu trúc ứng dụng
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner debug góc phải
      home: HomeScreen(), // Set HomeScreen làm màn hình đầu tiên
    );
  }
}

// // Lớp chính quản lý cấu trúc ứng dụng
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, // Tắt banner debug góc phải
//       home: TaskOverviewScreen(), // Set HomeScreen làm màn hình đầu tiên
//     );
//   }
// }