import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../models/appuser.dart';
import '../models/prescription.dart';
import '../models/medication.dart';
import '../services/hive_service.dart';
import '../services/postgreslocal_service.dart';

class SyncService {
  late final Dio _dio;

  SyncService() {
    _dio = PostgresLocalService().client;
  }

  Future<void> syncAll() async {
    await syncUsers();
    await syncPrescriptions();
  }

  // ----------------------------------------------------------
  // SYNC USERS
  // ----------------------------------------------------------
  Future<void> syncUsers() async {
    final box = await Hive.openBox<AppUser>(HiveService.userBoxName);
    final unsynced = box.values.where((u) => !u.isSynced).toList();

    for (final user in unsynced) {
      try {
        final userJson = user.toJson();

        // Remove fields the DB fills automatically
        userJson.remove('createdAt');
        userJson.remove('updatedAt');
        userJson['issynced'] = true; // Make sure name matches DB column

        final response = await _dio.post(
          '/app_users',
          data: userJson,
          options: Options(
            headers: {
              'Prefer': 'resolution=merge-duplicates,return=representation',
            },
          ),
        );

        print("▶ POST /app_users => ${response.statusCode}");

        user.isSynced = true;
        user.updatedAt = DateTime.now();
        await user.save();

        print('✅ User ${user.id} synced successfully');
      } catch (e) {
        print('❌ Failed to sync user ${user.email}: $e');
      }
    }
  }

  // ----------------------------------------------------------
  // SYNC PRESCRIPTIONS
  // ----------------------------------------------------------
  Future<void> syncPrescriptions() async {
    final box = await Hive.openBox<Prescription>(HiveService.prescriptionBoxName);
    final unsynced = box.values.where((p) => !p.isSynced).toList();

    for (final p in unsynced) {
      try {
        final json = p.toJson();
        json['issynced'] = true;

        final response = await _dio.post(
          '/prescriptions',
          data: json,
          options: Options(
            headers: {
              'Prefer': 'resolution=merge-duplicates,return=representation',
            },
          ),
        );

        print("▶ POST /prescriptions => ${response.statusCode}");

        p.isSynced = true;
        p.updatedAt = DateTime.now();
        await p.save();

        print('✅ Prescription ${p.id} synced successfully');
      } catch (e) {
        print('❌ Failed to sync prescription ${p.id}: $e');
      }
    }

    // ----------------------------------------------------------
    // CLEANUP / ARCHIVE LOGIC
    // ----------------------------------------------------------
    try {
      final response = await _dio.get('/prescriptions?isarchived=eq.false&select=id');
      final cloudIds = (response.data as List)
          .map((p) => p['id'].toString())
          .toSet();

      final localIds = box.values
          .where((p) => !p.isArchived)
          .map((p) => p.id)
          .toSet();

      final idsToArchive = cloudIds.difference(localIds);

      for (final id in idsToArchive) {
        try {
          await _dio.patch(
            '/prescriptions?id=eq.$id',
            data: {'isarchived': true, 'issynced': true},
          );
          print('🗑️ Archived prescription $id');
        } catch (e) {
          print('❌ Failed to archive prescription $id: $e');
        }
      }
    } catch (e) {
      print('❌ Failed to fetch cloud prescriptions for archival sync: $e');
    }

    // ----------------------------------------------------------
    // DOWNLOAD CLOUD → LOCAL
    // ----------------------------------------------------------
    try {
      final response = await _dio.get('/prescriptions?isarchived=eq.false');
      final records = response.data as List;

      for (final record in records) {
        final prescription = Prescription.fromJson(record);

        // Make sure medications list is parsed
        if (record['medications'] is List) {
          prescription.medications = (record['medications'] as List)
              .map((m) => Medication.fromJson(m as Map<String, dynamic>))
              .toList();
        }

        if (!box.values.any((p) => p.id == prescription.id)) {
          await box.put(prescription.id, prescription);
        }
      }
    } catch (e) {
      print('❌ Failed to download prescriptions: $e');
    }
  }
}
