import 'package:hive/hive.dart';
import '../models/appuser.dart';
import '../models/prescription.dart';
import '../models/medication.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';

class SyncService {
  final _supabase = SupabaseService().client;

  Future<void> syncAll() async {
    await syncUsers();
    await syncPrescriptions();
  }

  /// 🔄 Sync AppUsers
  Future<void> syncUsers() async {
    final box = await Hive.openBox<AppUser>(HiveService.userBoxName);
    final unsynced = box.values.where((u) => !u.isSynced).toList();

    // Upload unsynced Hive users to Supabase
    for (final user in unsynced) {
      try {
        await _supabase.from('app_users').upsert(user.toJson());
        user.isSynced = true;
        user.updatedAt = DateTime.now();
        await user.save();
      } catch (e) {
        print('❌ Failed to sync user ${user.email}: $e');
      }
    }

    // Download any new server users (optional)
    final response = await _supabase
        .from('app_users')
        .select()
        .neq('is_synced', false);

    for (final record in response) {
      final remoteUser = AppUser.fromJson(record);
      if (!box.values.any((u) => u.id == remoteUser.id)) {
        await box.put(remoteUser.id, remoteUser);
      }
    }
  }

  /// 🔄 Sync Prescriptions
  /// 🔄 Sync Prescriptions with embedded medications
  Future<void> syncPrescriptions() async {
    final box = await Hive.openBox<Prescription>('prescriptions');
    final unsynced = box.values.where((p) => !p.isSynced).toList();

    for (final p in unsynced) {
      try {
        final prescriptionJson = p.toJson();
        // Convert medications to JSON for Supabase
        prescriptionJson['medications'] =
            p.medications.map((m) => m.toJson()).toList();

        await _supabase.from('prescriptions').upsert(prescriptionJson);

        p.isSynced = true;
        p.updatedAt = DateTime.now();
        await p.save();
      } catch (e) {
        print('❌ Failed to sync prescription ${p.id}: $e');
      }
    }

    // Download prescriptions with medications embedded
    final response = await _supabase.from('prescriptions').select();

    for (final record in response) {
      final prescription = Prescription.fromJson(record);
      // Deserialize embedded medications
      if (record['medications'] != null) {
        final meds =
            (record['medications'] as List)
                .map((json) => Medication.fromJson(json))
                .toList();
        prescription.medications = meds;
      }

      if (!box.values.any((p) => p.id == prescription.id)) {
        await box.put(prescription.id, prescription);
      }
    }
  }
}
