import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/prescription_list.dart';
import 'services/hive_service.dart';
import 'services/medication_scheduler.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure logging
  Logger.root.level =
      Level
          .ALL; // Set to Level.ALL for full debugging, or Level.INFO, Level.WARNING, etc.
  Logger.root.onRecord.listen((record) {
    // Print logs to the console
    print(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  // await HiveService.init();
  // final medicationScheduler = MedicationScheduler(
  //   HiveService.getPrescriptionBox(),
  // );
  // await medicationScheduler.initialize();
  await requestExactAlarmPermission();
  await requestNotificationPermission();
  await testImmediateNotification();
  // await medicationScheduler.scheduleAllMedications();
  final cameras = await availableCameras();
  runZonedGuarded(
    () {
      runApp(PrescriptionScannerApp(cameras: cameras));
    },
    (error, stackTrace) {
      Logger('Global').severe('Uncaught error', error, stackTrace);
    },
  );
}

Future<void> requestNotificationPermission() async {
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

Future<void> requestExactAlarmPermission() async {
  const platform = MethodChannel('exact_alarm_permission');

  try {
    await platform.invokeMethod('requestExactAlarmPermission');
  } on PlatformException catch (e) {
    print("❌ Failed to request exact alarm permission: $e");
  }
  final alarmStatus = await Permission.scheduleExactAlarm.status;
  print("Alarm Permission: ${alarmStatus.isGranted}");
}

Future<void> testImmediateNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      print('🔔 Notification clicked: ${response.payload}');
    },
    onDidReceiveBackgroundNotificationResponse: (response) {
      print('🔔 Background notification clicked: ${response.payload}');
    },
  );

  const androidDetails = AndroidNotificationDetails(
    'medication_channel',
    'Medication Alerts',
    channelDescription: 'Reminder to take your medicine',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentSound: true,
    presentBadge: true,
  );

  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    1,
    'Test Notification 1',
    'This is a test alert 1',
    notificationDetails,
  );
  final scheduledTime = tz.TZDateTime.now(
    tz.local,
  ).add(const Duration(seconds: 30));
  print('Scheduling notification for: $scheduledTime');
  print('Current time is: ${tz.TZDateTime.now(tz.local)}');
  await flutterLocalNotificationsPlugin.zonedSchedule(
    2,
    'Test Notification 2',
    'This is a test alert 2',
    scheduledTime,
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

class PrescriptionScannerApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const PrescriptionScannerApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescription Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PrescriptionListScreen(
        initialPrescriptions: HiveService.getAllPrescriptions(),
        cameras: cameras,
      ),
    );
  }
}
