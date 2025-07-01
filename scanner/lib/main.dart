import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'ui/prescription_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(PrescriptionScannerApp(cameras: cameras));
}

class PrescriptionScannerApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const PrescriptionScannerApp({Key? key, required this.cameras})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescription Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PrescriptionHomePage(cameras: cameras),
    );
  }
}
