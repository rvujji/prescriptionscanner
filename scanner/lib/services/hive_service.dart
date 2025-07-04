import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import '../models/prescription.dart';
import '../models/medication.dart';

final Logger _logger = Logger('HiveService');

class HiveService {
  static const String _prescriptionBoxName = 'prescriptions';

  static Future<void> init() async {
    try {
      _logger.info('Initializing Hive...');
      await Hive.initFlutter();

      Hive.registerAdapter(PrescriptionAdapter());
      Hive.registerAdapter(MedicationAdapter());
      Hive.registerAdapter(DosageAdapter());
      Hive.registerAdapter(AdministrationTimeAdapter());
      Hive.registerAdapter(DosageUnitAdapter());
      Hive.registerAdapter(TimeUnitAdapter());
      Hive.registerAdapter(DurationPeriodAdapter());

      await Hive.openBox<Prescription>(_prescriptionBoxName);
      _logger.info('Hive initialized and box opened successfully.');
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize Hive: $e', e, stackTrace);
      rethrow;
    }
  }

  static Box<Prescription> getPrescriptionBox() {
    return Hive.box<Prescription>(_prescriptionBoxName);
  }

  static Future<void> savePrescription(Prescription prescription) async {
    final box = getPrescriptionBox();

    try {
      _logger.info('Saving prescription with ID: ${prescription.id}');

      // Create a deep copy
      final prescriptionCopy = Prescription(
        id: prescription.id,
        date: prescription.date,
        patientName: prescription.patientName,
        doctorName: prescription.doctorName,
        medications:
            prescription.medications.map((m) {
              _logger.fine('Copying medication with ID: ${m.id}');
              return Medication(
                id: m.id,
                name: m.name,
                dosage: m.dosage,
                times: m.times,
                duration: m.duration,
              );
            }).toList(),
        notes: prescription.notes,
        imagePath: prescription.imagePath,
      );

      await box.put(prescriptionCopy.id, prescriptionCopy);
      _logger.info('Prescription [${prescription.id}] saved successfully.');
    } catch (e, stackTrace) {
      _logger.severe(
        'Error saving prescription [${prescription.id}]: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  static List<Prescription> getAllPrescriptions() {
    try {
      final box = getPrescriptionBox();
      final prescriptions = box.values.toList();
      _logger.fine('Retrieved ${prescriptions.length} prescriptions.');
      return prescriptions;
    } catch (e, stackTrace) {
      _logger.severe('Error retrieving prescriptions: $e', e, stackTrace);
      return [];
    }
  }

  static Future<void> deletePrescription(String id) async {
    final box = getPrescriptionBox();

    try {
      _logger.info('Attempting to delete prescription with ID: $id');
      final index = box.values.toList().indexWhere((p) => p.id == id);

      if (index != -1) {
        await box.deleteAt(index);
        _logger.info('Prescription [$id] deleted.');
      } else {
        _logger.warning('Prescription with ID $id not found for deletion.');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error deleting prescription [$id]: $e', e, stackTrace);
      rethrow;
    }
  }
}
