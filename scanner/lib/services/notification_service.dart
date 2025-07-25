import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:developer' as developer;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import '../widgets/notification_viewer.dart';
import '../services/navigation_service.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point') // required so Flutter doesn't tree-shake this
void notificationTapBackground(NotificationResponse response) {
  developer.log('🔔 Background notification clicked: ${response.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  final FlutterTts _flutterTts = FlutterTts();
  final String _logTag = 'NotificationService';

  void Function(String? payload)? onNotificationTap;

  Future<void> initialize({void Function(String? payload)? onTap}) async {
    try {
      developer.log('Initializing NotificationService...', name: _logTag);
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      _notificationsPlugin = FlutterLocalNotificationsPlugin();
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      onNotificationTap = onTap;
      const androidIinit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidIinit,
        iOS: iosInit,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) async {
          final payload = response.payload;
          developer.log('🔔 Notification tapped: $payload', name: _logTag);
          if (payload != null && payload.isNotEmpty) {
            final data = jsonDecode(payload);
            final message = data['message'];
            final imagePath = data['imagePath'];
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder:
                    (_) => NotificationViewScreen(
                      message: message,
                      imagePath: imagePath,
                    ),
              ),
            );
            // await _flutterTts.speak(payload);
          }
          if (onNotificationTap != null) {
            onNotificationTap!(payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
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
    bool isForever = false,
    String? imagePath,
  }) async {
    try {
      final contextInfo =
          '[prescriptionId=${prescriptionId ?? "?"}, medicationId=${medicationId ?? "?"}]';

      developer.log(
        'Scheduling medication notification $contextInfo → '
        'id=$id, title="$title", time=$scheduledTime, isForever=$isForever',
        name: _logTag,
      );

      final androidDetails = const AndroidNotificationDetails(
        'medication_channel',
        'Medication Reminders',
        channelDescription: 'Notifications for medication',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: isForever ? DateTimeComponents.time : null,
        payload: jsonEncode({
          'message': '$title. $body',
          'imagePath': imagePath,
        }),
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
