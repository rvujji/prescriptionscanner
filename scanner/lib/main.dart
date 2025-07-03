import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'widgets/prescription_list.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      ),
    );
  }
}
