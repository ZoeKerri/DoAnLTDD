import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  final List<ToDo> foundToDo;

  const SettingsPage({
    required this.foundToDo,
    super.key,
  });

  Future<Map<String, String>> initUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('currentUsername') ?? '';
    String gmail = prefs.getString('currentEmail') ?? '';
    String id = prefs.getString('currentUserId') ?? '';
    return {'name': name, 'gmail': gmail, 'id': id};
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Đăng xuất'),
              onPressed: () {
                Navigator.of(dialogContext).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LogInScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Trong lớp SettingsPage
  Map<String, Map<String, int>> _getToDoSummary() {
    int todayDoneCount = 0;
    int todayPendingCount = 0;
    int thisWeekDoneCount = 0;
    int thisWeekPendingCount = 0;
    int thisYearDoneCount = 0;
    int thisYearPendingCount = 0;
    int allDoneCount = 0;
    int allPendingCount = 0;

    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Tính toán đầu tuần (thứ Hai)
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    final DateTime startOfYear = DateTime(now.year, 1, 1);
    final DateTime endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    for (var todo in foundToDo) {
      if (todo.isDone == true) {
        allDoneCount++;
      } else {
        allPendingCount++;
      }

      if (todo.date != null) {
        final DateTime todoDate = todo.date!;

        // ToDo hôm nay
        if (todoDate.isAfter(startOfToday) && todoDate.isBefore(endOfToday)) {
          if (todo.isDone == true) {
            todayDoneCount++;
          } else {
            todayPendingCount++;
          }
        }

        // ToDo tuần này
        // Sử dụng Range Check an toàn hơn để bao gồm cả đầu và cuối ngày/tuần
        if (todoDate.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
            todoDate.isBefore(endOfWeek.add(const Duration(milliseconds: 1)))) {
          if (todo.isDone == true) {
            thisWeekDoneCount++;
          } else {
            thisWeekPendingCount++;
          }
        }
        
        // ToDo năm nay
        if (todoDate.isAfter(startOfYear.subtract(const Duration(milliseconds: 1))) &&
            todoDate.isBefore(endOfYear.add(const Duration(milliseconds: 1)))) {
          if (todo.isDone == true) {
            thisYearDoneCount++;
          } else {
            thisYearPendingCount++;
          }
        }
      }
    }

    return {
      'today': {
        'done': todayDoneCount,
        'pending': todayPendingCount,
      },
      'thisWeek': {
        'done': thisWeekDoneCount,
        'pending': thisWeekPendingCount,
      },
      'thisYear': {
        'done': thisYearDoneCount,
        'pending': thisYearPendingCount,
      },
      'all': {
        'done': allDoneCount,
        'pending': allPendingCount,
      },
    };
  }
  // Trong lớp SettingsPage
  void _showSummaryDialog(BuildContext context) {
    final Map<String, Map<String, int>> summary = _getToDoSummary();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tóm Tắt Hoạt Động'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tổng số ToDo
              Text(
                'Tổng số ToDo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('  Đã hoàn thành: ${summary['all']!['done']}'),
              Text('  Chưa hoàn thành: ${summary['all']!['pending']}'),
              const SizedBox(height: 12),

              // ToDo hôm nay
              Text(
                'ToDo Hôm nay:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('  Đã hoàn thành: ${summary['today']!['done']}'),
              Text('  Chưa hoàn thành: ${summary['today']!['pending']}'),
              const SizedBox(height: 12),

              // ToDo tuần này
              Text(
                'ToDo Tuần này:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('  Đã hoàn thành: ${summary['thisWeek']!['done']}'),
              Text('  Chưa hoàn thành: ${summary['thisWeek']!['pending']}'),
              const SizedBox(height: 12),

              // ToDo năm nay
              Text(
                'ToDo Năm nay:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('  Đã hoàn thành: ${summary['thisYear']!['done']}'),
              Text('  Chưa hoàn thành: ${summary['thisYear']!['pending']}'),
              const SizedBox(height: 16),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  String shortenString(String text, int maxLength) {
  if (text.length > maxLength) {
    final int halfLength = (maxLength - 3) ~/ 2;  // chia lấy nguyên
    return text.substring(0, halfLength) + '...' + text.substring(text.length - halfLength);
  }
  return text;
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: initUserInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userInfo = snapshot.data!;
        final userID = shortenString(userInfo['id']!, 30);
        final userName = shortenString(userInfo['name']!, 30);
        final userGmail = shortenString(userInfo['gmail']!, 30);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 195, 255), 
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white), 
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            title: const Text(
              'Thông tin người dùng',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          ),
          centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Thông tin người dùng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'ID:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              userID,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Username:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              userName,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Gmail:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              userGmail,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showSummaryDialog(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.summarize, color: Colors.deepOrange),
                          SizedBox(width: 12),
                          Text(
                            'Tóm tắt hoạt động',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showLogoutConfirmationDialog(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.logout, color: Colors.deepOrange),
                          SizedBox(width: 12),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
