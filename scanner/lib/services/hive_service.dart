// services/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/prescription.dart';
import '../models/medication.dart';

class HiveService {
  static const String _prescriptionBoxName = 'prescriptions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PrescriptionAdapter());
    Hive.registerAdapter(MedicationAdapter());
    await Hive.openBox<Prescription>(_prescriptionBoxName);
  }

  static Box<Prescription> getPrescriptionBox() {
    return Hive.box<Prescription>(_prescriptionBoxName);
  }

  static Future<void> savePrescription(Prescription prescription) async {
    final box = getPrescriptionBox();
    await box.add(prescription);
  }

  static List<Prescription> getAllPrescriptions() {
    final box = getPrescriptionBox();
    return box.values.toList();
  }

  static Future<void> deletePrescription(String id) async {
    final box = getPrescriptionBox();
    final index = box.values.toList().indexWhere((p) => p.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }
}
