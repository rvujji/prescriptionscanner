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
        final userJson = user.toJson();
        userJson['issynced'] = true;
        await _supabase.from('app_users').upsert(userJson);
        user.isSynced = true;
        user.updatedAt = DateTime.now();
        await user.save();
        print('✅ User ${user.id} synced successfully');
      } catch (e) {
        print('❌ Failed to sync user ${user.email}: $e');
      }
    }
    //users cant be synced back from server to client
  }

  //sync oauth users
  // Future<void> syncOauthUsers(AppUser user) async {
  //   await _supabase.from('app_users').upsert({
  //     'id': user?.id,
  //     'email': user?.email,
  //     'name': user?.userMetadata?['name'] ?? '',
  //     'issynced': true,
  //   });
  // }

  /// 🔄 Sync Prescriptions with embedded medications
  Future<void> syncPrescriptions() async {
    final box = await Hive.openBox<Prescription>(
      HiveService.prescriptionBoxName,
    );
    final unsynced = box.values.where((p) => !p.isSynced).toList();

    for (final p in unsynced) {
      try {
        final prescriptionJson = p.toJson();
        prescriptionJson['issynced'] = true;
        // Convert medications to JSON for Supabase
        prescriptionJson['medications'] =
            p.medications.map((m) => m.toJson()).toList();

        await _supabase.from('prescriptions').upsert(prescriptionJson);
        p.isSynced = true;
        p.updatedAt = DateTime.now();
        await p.save();
        print('✅ Prescription ${p.id} synced successfully');
      } catch (e) {
        print('❌ Failed to sync prescription ${p.id}: $e');
      }
    }

    // 🗑️ Delete prescriptions from Supabase that no longer exist in Hive
    try {
      final cloudPrescriptions = await _supabase
          .from('prescriptions')
          .select('id');

      final cloudIds =
          cloudPrescriptions.map((p) => p['id'].toString()).toSet();
      final localIds = box.values.map((p) => p.id).toSet();
      final idsToDelete = cloudIds.difference(localIds);

      for (final id in idsToDelete) {
        try {
          await _supabase.from('prescriptions').delete().eq('id', id);
          print('🗑️ Deleted prescription $id from Supabase');
        } catch (e) {
          print('❌ Failed to delete prescription $id: $e');
        }
      }
    } catch (e) {
      print('❌ Failed to fetch cloud prescriptions for deletion sync: $e');
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
