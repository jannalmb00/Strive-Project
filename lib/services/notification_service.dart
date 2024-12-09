import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(NotificationResponse notificationResponse) async {
    // Handle notification response
    print("Notification clicked: ${notificationResponse.payload}");
  }

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
    );
  }

  static Future<bool> requestPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<void> sendStreakNotification() async {
    bool permissionGranted = await requestPermission();
    if (!permissionGranted) {
      print("Notification permission not granted");
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'streak_channel',
      'Streak Notifications',
      channelDescription: 'Notifications for streak updates.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Streak Level Up!',
      'Congratulations! Your streak points have been updated 🥳🎉.',
      notificationDetails,
    );
  }
}
