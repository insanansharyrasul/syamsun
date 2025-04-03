import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (detail) {},
    );
  }

  static Future<void> scheduledNotification(
      {required String prayerName, required DateTime prayerTime}) async {
    // Vibration pattern: wait 0ms, vibrate 1000ms, wait 500ms, vibrate 2000ms
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 2000]);
    tz.initializeTimeZones();
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
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
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static void showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await LocalNotifications._flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
