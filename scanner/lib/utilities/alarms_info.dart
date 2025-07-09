import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> checkScheduledNotifications() async {
  final List<PendingNotificationRequest> pendingNotifications =
      await notificationsPlugin.pendingNotificationRequests();

  if (pendingNotifications.isEmpty) {
    print('No pending notifications found.');
    return;
  }

  print('--- Scheduled Notifications ---');
  for (final notification in pendingNotifications) {
    print('''
      ID: ${notification.id}
      Title: ${notification.title}
      Body: ${notification.body}
      Scheduled for: ${notification.payload}
    ''');
  }
}
