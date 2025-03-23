import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<bool> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  static Future<void> showNotification() async {
    final hasPermission = await _requestNotificationPermission();
    if (!hasPermission) {
      print('Không có quyền hiển thị thông báo');
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(
      0,
      'Xin chào!',
      'Bạn vừa nhấn nút thành công 🎉',
      notificationDetails,
    );
  }

  static Future<void> scheduleNotification(int hour, int minute) async {
    final hasPermission = await _requestNotificationPermission();
    if (!hasPermission) {
      print('Không có quyền hiển thị thông báo');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'schedule_channel_id',
      'Schedule Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.zonedSchedule(
      1,
      'Thông báo hẹn giờ ⏰',
      'Đã đến ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }
}