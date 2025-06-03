import 'package:flutter/material.dart';

class DashboardLayout extends StatelessWidget {
  // Các thành phần UI linh hoạt được truyền qua constructor
  final Widget createSchedule;
  final Widget history;
  final Widget statistics;
  final Widget donate;

  const DashboardLayout({
    required this.createSchedule,
    required this.history,
    required this.statistics,
    required this.donate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Phần trên chiếm 30% chiều cao (flex 3/10)
        Expanded(
          flex: 3, // 30% tổng chiều cao
          child: createSchedule, // Widget tạo lịch trình
        ),
        
        // Phần dưới chiếm 70% chiều cao (flex 7/10)
        Expanded(
          flex: 7,
          child: Row(
            children: [
              // Cột trái chiếm 50% chiều rộng
              Expanded(flex: 5, child: history), // Lịch sử
              
              // Cột phải chia đôi chiều cao
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Expanded(flex: 35, child: statistics), // Thống kê (50% chiều cao)
                    Expanded(flex: 35, child: donate), // Đóng góp (50% chiều cao)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}