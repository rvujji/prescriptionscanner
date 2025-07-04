import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'widgets/prescription_list.dart';
import 'services/hive_service.dart';
import 'package:logging/logging.dart';

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
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('StackTrace: ${record.stackTrace}');
    }
  });

  await HiveService.init();

  final cameras = await availableCameras();
  runApp(PrescriptionScannerApp(cameras: cameras));
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
