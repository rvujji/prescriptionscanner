import '../models/prescription.dart';
import 'hive_service.dart';

class PrescriptionService {
  Future<List<Prescription>> getAllPrescriptions() async {
    return HiveService.getAllPrescriptions();
  }

  Future<void> savePrescription(Prescription prescription) async {
    await HiveService.savePrescription(prescription);
  }

  Future<void> deletePrescription(String id) async {
    await HiveService.deletePrescription(id);
  }
}
