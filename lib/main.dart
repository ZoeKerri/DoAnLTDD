// Import thư viện Flutter Material và màn hình chính
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/TaskOverviewScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';//firebase thì chịu tạm thời chưa up realtime được 
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:doanltdd/service/notification.dart';

//LƯU Ý PHẢI CHẠY TRÊN GIẢ LẬP ANDROID CHỨ CHẠY TRÊN WEB NÓ K LOAD ĐƯỢC SQLITE

// Điểm bắt đầu của ứng dụng - chạy widget gốc MyApp
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final status = await Permission.notification.request();
  if (!status.isGranted) {
    SystemNavigator.pop();
    return;
  }
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  await NotificationService.initialize();
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