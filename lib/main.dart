// Import thư viện Flutter Material và màn hình chính
import 'package:doanltdd/screens/TaskOverviewScreen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';//firebase chưa xong sẽ tiếp tục làm tiếp 


//LƯU Ý PHẢI CHẠY TRÊN GIẢ LẬP ANDROID CHỨ CHẠY TRÊN WEB NÓ K LOAD ĐƯỢC SQLITE


// Lớp chính quản lý cấu trúc ứng dụng
void main() async{
  // WidgetsFlutterBinding.ensureInitialized();
  // await NotificationService.initialize();
  // NotificationService.scheduleNotification(14, 43);//test thông báo khi đến giờ (sẽ tiếp tục xây dựng tiếp sau)
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