import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = const InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (detail) {},
    );
  }

  static Future<void> scheduledNotification(
      {required String prayerName, required DateTime prayerTime}) async {
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 2000]);
    tz.initializeTimeZones();
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'prayer_channel_id',
      'Prayer Notifications',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode,
      'Prayer Time',
      'It\'s time for $prayerName prayer',
      tz.TZDateTime.from(
        prayerTime,
        tz.local,
      ),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduledSleeepNotification(
      {required String id, required DateTime setTime}) async {
    final vibrationPattern = Int64List.fromList([0, 500, 500, 1000]);
    tz.initializeTimeZones();
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'sleep_channel_id',
      'Sleep Notifications',
      channelDescription: 'Notifications for sleep times',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode,
      'Sleep TIme',
      'It\'s time for sleep',
      tz.TZDateTime.from(
        setTime,
        tz.local,
      ),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
