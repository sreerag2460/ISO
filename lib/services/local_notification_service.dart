import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // static void initialize() {
  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(
  //           android: AndroidInitializationSettings(
  //     "@mipmap/ic_launcher",
  //   ));
  //   _notificationsPlugin.initialize(initializationSettings);
  // }

  static void display(RemoteMessage message) async {
    try {
      final id = Random().nextInt((pow(2, 31) - 1).toInt());
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            "VelocityISO", "VelocityISO channel",
            channelDescription: "this is our channel",
            importance: Importance.max,
            priority: Priority.high),
      );
      await _notificationsPlugin.show(id, message.notification?.title,
          message.notification?.body, notificationDetails);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}
