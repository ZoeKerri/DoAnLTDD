import 'package:doanltdd/screens/TaskOverviewScreen.dart';
import 'package:flutter/material.dart';
import 'todo_screen.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/menu_card.dart';
import 'login_screen.dart'; 
import 'package:doanltdd/database/database_helper.dart';
import 'package:doanltdd/database/firebase_db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Lưu trạng thái của tab hiện tại

  late String _currentUserId;

  //Khởi tạo data từ firebase về hoặc từ sqlite lên
  @override
  void initState() {
    super.initState();
    initToDoData(); 
  }

  Future<void> initToDoData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('currentUserId') ?? '';
    print("=== [DEBUG] currentUserId = $_currentUserId ===");
    final localToDos = await DatabaseHelper.instance.getAllToDos();
    final firebaseService = FirebaseDBService();

    //chưa có dữ liệu trong sqlite thì lấy trên firebase
    if (localToDos.isEmpty) {
      await firebaseService.syncToDoFromFirebase(_currentUserId);
      final newData = await DatabaseHelper.instance.getAllToDos();
      if(newData.isEmpty) print("Chưa có dữ liệu ở cả 2 firebase và sqlite");
    }

    //có dữ liệu thì đồng bộ sqlite lên firebase để xem máy local có bị gì k 
    else{
      await firebaseService.syncToDoToFirebase();
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Khi nhấn vào tab "Tài khoản", chuyển sang màn hình LogInScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LogInScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index; // Chỉ cập nhật index nếu là tab Home
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Hoang Phu Test'),
        backgroundColor: Colors.white,
        elevation: 4,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.shade800,
                width: 2,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () => print('Đã chọn thông báo'),
              splashRadius: 20,
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
      body: HomeContent(), // Chỉ hiển thị nội dung Home, không cần đổi theo tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Xử lý khi nhấn vào tab
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

// Phần nội dung của màn hình Home (không thay đổi)
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      createSchedule: MenuCard(
        title: 'Tạo lịch',
        color: Colors.blue[200]!,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TodoScreen()),
          );
        },
      ),
      history: MenuCard(
        title: 'Lịch sử',
        color: Colors.green[200]!,
        onTap: () {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskOverviewScreen()),
      );},
      ),
      statistics: MenuCard(
        title: 'Thống kê',
        color: Colors.orange[200]!,
        onTap: () async {
          }
      ),
      donate: MenuCard(
        title: 'Đóng góp',
        color: Colors.purple[200]!,
        onTap: () => print('Đã chọn đóng góp'),
      ),
    );
  }
}
