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
    Hive.registerAdapter(DosageAdapter());
    Hive.registerAdapter(AdministrationTimeAdapter());
    Hive.registerAdapter(DosageUnitAdapter());
    Hive.registerAdapter(TimeUnitAdapter());
    await Hive.openBox<Prescription>(_prescriptionBoxName);
  }

  static Box<Prescription> getPrescriptionBox() {
    return Hive.box<Prescription>(_prescriptionBoxName);
  }

  static Future<void> savePrescription(Prescription prescription) async {
    final box = getPrescriptionBox();

    // Create a DEEP COPY of the prescription before saving
    final prescriptionCopy = Prescription(
      id: prescription.id,
      date: prescription.date,
      patientName: prescription.patientName,
      doctorName: prescription.doctorName,
      medications:
          prescription.medications
              .map(
                (m) => Medication(
                  name: m.name,
                  dosage: m.dosage,
                  times: m.times,
                  duration: m.duration,
                ),
              )
              .toList(),
      notes: prescription.notes,
      imagePath: prescription.imagePath,
    );

    await box.put(prescriptionCopy.id, prescriptionCopy);
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
