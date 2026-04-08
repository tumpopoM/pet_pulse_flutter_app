import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final dynamic timezoneData = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneData.toString();

    print('--- Debug Timezone: $timeZoneName ---');

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print('Timezone error, falling back to Bangkok: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSetting,
    );
    await _notifications.initialize(settings);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_pulse_channel',
          'PetPulse Notifications',
          channelDescription: 'แจ้งเตือนวันฉีดวัคซีนน้องแมว',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> requestPermission() async {
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> showInstantNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'ทดสอบเด้งทันที!',
      'ถ้าเห็นข้อความนี้ แสดงว่าระบบ UI พร้อมทำงานค่ะ',
      notificationDetails,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('🗑️ ยกเลิกการแจ้งเตือน ID: $id สำเร็จ');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
