import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class AppInitializer {
  static Future<void> initializeAll() async {
    await testNetwork();
    final notificationService = NotificationService();
    await notificationService.initialize(onTap: (payload) {});
    await HiveService.init();
    await SupabaseService().initialize();
    await requestNotificationPermission();
    await requestExactAlarmPermission();
  }

  static Future<void> testNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('✅ Device is online');
      }
    } catch (e) {
      print('❌ No Internet: $e');
    }
  }

  static Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print("🔔 Notification permission granted.");
      } else {
        print("🚫 Notification permission denied.");
      }
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      const platform = MethodChannel('exact_alarm_permission');

      try {
        await platform.invokeMethod('requestExactAlarmPermission');
      } on PlatformException catch (e) {
        print("❌ Failed to request exact alarm permission: $e");
      }
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      print("Alarm Permission: ${alarmStatus.isGranted}");
    }
  }
}
