import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  // Các props tùy biến được truyền từ bên ngoài
  final String title;
  final Color color;
  final VoidCallback onTap; // Callback khi nhấn

  const MenuCard({super.key, 
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Khoảng cách viền 8px
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: color, // Màu nền tùy chỉnh
          foregroundColor: Colors.black, // Màu chữ cố định
          minimumSize: const Size(double.infinity, double.infinity), // Chiếm toàn bộ không gian
          shape: RoundedRectangleBorder( // Bo góc 10px
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 24),  // Font size lớn cho dễ tương tác
        ),
      ),
    );
  }
}