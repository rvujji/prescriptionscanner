import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/prescription_list.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/medication_scheduler.dart';
import 'dart:async';

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

  await HiveService.init();
  final medicationScheduler = MedicationScheduler(
    HiveService.getPrescriptionBox(),
  );
  await medicationScheduler.initialize();
  await requestNotificationPermission();
  await medicationScheduler.scheduleAllMedications();
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
