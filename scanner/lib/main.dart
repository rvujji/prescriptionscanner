// main.dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'services/hive_service.dart';
import 'services/supabase_service.dart';
import 'services/navigation_service.dart';
import 'widgets/auth/login_screen.dart';
import 'widgets/auth/register_screen.dart';
import 'widgets/prescription_list.dart';
import 'utils/initializer.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized(); // Moved inside the zone

      // Configure logging
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        print(
          '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
        );
      });

      await AppInitializer.initializeAll();
      runApp(PrescriptionScannerApp());
    },
    (error, stackTrace) {
      Logger('Global').severe('Uncaught error', error, stackTrace);
    },
  );
}

@pragma('vm:entry-point') // required so Flutter doesn't tree-shake this
void notificationTapBackground(NotificationResponse response) {
  print('🔔 Background notification clicked: ${response.payload}');
}

class PrescriptionScannerApp extends StatelessWidget {
  const PrescriptionScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescription Manager',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: HiveService.isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == true) {
            // If already logged in, load prescriptions directly
            return FutureBuilder<List<CameraDescription>>(
              future: availableCameras(),
              builder: (context, cameraSnapshot) {
                if (!cameraSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return PrescriptionListScreen(
                  initialPrescriptions: HiveService.getAllPrescriptions(),
                  cameras: cameraSnapshot.data!,
                );
              },
            );
          }

          // If not logged in, show login screen
          return LoginScreen(
            onRegisterTap: () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
