import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  final String _logTag = 'NotificationService';

  Future<void> initialize() async {
    try {
      developer.log('Initializing NotificationService...', name: _logTag);
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      _notificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          developer.log(
            'Notification tapped: ${details.payload}',
            name: _logTag,
          );
        },
      );

      developer.log(
        'NotificationService initialized successfully',
        name: _logTag,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Initialization failed: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> scheduleMedicationNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? prescriptionId,
    String? medicationId,
  }) async {
    try {
      final contextInfo =
          '[prescriptionId=${prescriptionId ?? "?"}, medicationId=${medicationId ?? "?"}]';

      developer.log(
        'Scheduling medication notification $contextInfo → '
        'id=$id, title="$title", time=$scheduledTime',
        name: _logTag,
      );

      final androidDetails = const AndroidNotificationDetails(
        'medication_channel',
        'Medication Reminders',
        channelDescription: 'Notifications for medication schedules',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      developer.log(
        'Scheduled notification $contextInfo with ID $id at $tzDateTime',
        name: _logTag,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to schedule notification: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      developer.log('Cancelling notification with ID $id', name: _logTag);
      await _notificationsPlugin.cancel(id);
      developer.log('Cancelled notification with ID $id', name: _logTag);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to cancel notification $id: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      developer.log('Cancelling all notifications', name: _logTag);
      await _notificationsPlugin.cancelAll();
      developer.log('All notifications cancelled', name: _logTag);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to cancel all notifications: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
