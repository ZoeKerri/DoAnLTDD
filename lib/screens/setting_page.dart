import 'package:flutter/material.dart';
import 'login_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        leading: IconButton( // Nút quay lại
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Quay lại màn hình trước
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              'Đăng xuất',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.logout),
            onTap: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
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
                Navigator.of(dialogContext).pop(); // Đóng dialog
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
}