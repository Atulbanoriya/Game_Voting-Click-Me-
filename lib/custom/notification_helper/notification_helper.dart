import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static List<Map<String, String?>> notifications = [];

  static void addNotification(RemoteMessage message) {
    if (message.notification != null) {
      notifications.add({
        'title': message.notification!.title,
        'body': message.notification!.body,
      });
    }
  }

  static List<Map<String, String?>> getNotifications() {
    return notifications;
  }
}
