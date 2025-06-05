import 'package:doanltdd/screens/TaskOverviewScreen.dart';
import 'package:doanltdd/screens/donate_screen.dart';
import 'package:doanltdd/screens/setting_page.dart';
import 'package:flutter/material.dart';
import 'todo_screen.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/menu_card.dart';
import 'package:doanltdd/database/database_helper.dart';
import 'package:doanltdd/database/firebase_db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'statistics_screen..dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Lưu trạng thái của tab hiện tại

  late String _currentUserId;
  String _currentUsername = "";
  List<ToDo> allTodos = []; // Biến để lưu trữ tất cả ToDo đã tải

  // Khởi tạo data từ firebase về hoặc từ sqlite lên
  @override
  void initState() {
    super.initState();
    initToDoData();
  }

  Future<void> initToDoData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('currentUserId') ?? '';
    List<ToDo> fetchedToDos = await DatabaseHelper.instance.getAllToDos(); // Tải dữ liệu ban đầu từ SQLite

    final firebaseService = FirebaseDBService();

    // Nếu chưa có dữ liệu trong sqlite thì lấy trên firebase
    if (fetchedToDos.isEmpty) {
      await firebaseService.syncFromFirebase(_currentUserId);
      fetchedToDos = await DatabaseHelper.instance.getAllToDos(); // Tải lại nếu sync từ Firebase thành công
      if (fetchedToDos.isEmpty) {
        print("Chưa có dữ liệu ở cả 2 firebase và sqlite");
      }
    }
    // Nếu có dữ liệu thì đồng bộ sqlite lên firebase (để đảm bảo dữ liệu mới nhất)
    else {
      await firebaseService.syncToFirebase();
    }

    // Cập nhật trạng thái sau khi tải và đồng bộ dữ liệu
    setState(() {
      _currentUsername = prefs.getString('currentUsername') ?? '';
      allTodos = fetchedToDos; // Cập nhật danh sách ToDo
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Hello ',
            ),
            TextSpan(
              text: _currentUsername.length > 5
                  ? '${_currentUsername.substring(0, 5)}...'
                  : _currentUsername,
                   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 4,
      //Chức năng tương lai nếu làm tiếp
      // actions: [
      //   Container(
      //     margin: const EdgeInsets.all(8),
      //     decoration: BoxDecoration(
      //       color: Colors.blue,
      //       borderRadius: BorderRadius.circular(8),
      //       border: Border.all(
      //         color: Colors.blue.shade800,
      //         width: 2,
      //       ),
      //     ),
      //     child: IconButton(
      //       icon: const Icon(Icons.notifications, color: Colors.white),
      //       onPressed: () => print('Đã chọn thông báo'),
      //       splashRadius: 20,
      //       padding: const EdgeInsets.all(10),
      //     ),
      //   ),
      // ],
    ),
      // Truyền allTodos cho HomeContent
      body: HomeContent(todos: allTodos),
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


class HomeContent extends StatelessWidget {
  final List<ToDo> todos;

  const HomeContent({super.key, required this.todos});

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
          );
        },
      ),
      statistics: MenuCard(
        title: 'Thống kê',
        color: Colors.orange[200]!,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StatisticsScreen(
                todos: todos, 
              ),
            ),
          );
        },
      ),
      donate: MenuCard(
        title: 'Đóng góp',
        color: Colors.purple[200]!,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DonateScreen()),
          );
        }
      ),
    );
  }
}