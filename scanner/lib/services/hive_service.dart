// hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import '../models/prescription.dart';
import '../models/medication.dart';
import '../models/appuser.dart';
import '../utils/password_manager.dart';
import 'medication_scheduler.dart';
import 'sync_hive_supabase.dart';
import '../auth/google_signin.dart';

final Logger _logger = Logger('HiveService');

class HiveService {
  static const String prescriptionBoxName = 'prescriptions';
  static const String userBoxName = 'appusers';

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
      Hive.registerAdapter(AppUserAdapter());

      await Hive.openBox<Prescription>(prescriptionBoxName);
      await Hive.openBox<AppUser>(userBoxName);
      _logger.info('Hive initialized and box opened successfully.');
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize Hive: $e', e, stackTrace);
      rethrow;
    }
  }

  static Box<Prescription> getPrescriptionBox() {
    return Hive.box<Prescription>(prescriptionBoxName);
  }

  static Box<AppUser> getUserBox() {
    return Hive.box<AppUser>(userBoxName);
  }

  static Future<void> savePrescription(Prescription prescription) async {
     // Log or display in your app

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
                frontImagePath: m.frontImagePath,
                backImagePath: m.backImagePath,
                isSynced: false, //m.isSynced,
                createdAt: m.createdAt ?? DateTime.now(),
                updatedAt: m.updatedAt ?? DateTime.now(),
              );
            }).toList(),
        notes: prescription.notes,
        imagePath: prescription.imagePath,
        userId: prescription.userId,
        isSynced: prescription.isSynced,
        isArchived: prescription.isArchived,
        createdAt: prescription.createdAt ?? DateTime.now(),
        updatedAt: prescription.updatedAt ?? DateTime.now(),
      );

      await box.put(prescriptionCopy.id, prescriptionCopy);
      final medicationScheduler = MedicationScheduler(getPrescriptionBox());
      await medicationScheduler.scheduleMedicationsForPrescription(
        prescriptionCopy,
      );

      _logger.info('Prescription [${prescription.id}] saved successfully.');
      await SyncService().syncPrescriptions();
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
      final loggedInUser = HiveService.getLoggedInUser();
      if (loggedInUser == null) {
        _logger.warning('No user is logged in.');
        return [];
      }
      final prescriptions =
          box.values
              .where((prescription) => prescription.userId == loggedInUser.id && !prescription.isArchived)
              .toList();
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
      _logger.info('Attempting to archive prescription with ID: $id');
      final prescription = box.get(id);

      if (prescription != null) {
        prescription.isArchived = true;
        prescription.isSynced = false;
        await prescription.save();
        _logger.info('Prescription [$id] archived.');
        SyncService().syncPrescriptions();
      } else {
        _logger.warning('Prescription with ID $id not found for archival.');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error archiving prescription [$id]: $e', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> saveUser(AppUser user) async {
    await saveRegisteredUserToHive(user);
    /// todo: comment after development
    final hbox = Hive.box('userBoxName');
// Get all data as a list:
    List allData = hbox.keys.map((key) {
      final value = hbox.get(key);
      return { "key": key, "value": value };
    }).toList();
    print(allData);
    SyncService().syncUsers();
  }

  static Future<void> saveRegisteredUserToHive(AppUser user) async {
    try {
      _logger.info('Saving user with Email ID: ${user.name}');
      final usersBox = getUserBox();
      // Check if email or phone already exists
      final alreadyExists = usersBox.values.any(
        (u) => u.email == user.email || u.phone == user.phone,
      );
      if (alreadyExists) {
        throw ("User with same email or phone already exists.");
      }

      // Create a deep copy
      final userCopy = AppUser(
        id: user.id.isNotEmpty ? user.id : const Uuid().v4(),
        name: user.name,
        email: user.email,
        passwordHash: user.passwordHash,
        phone: user.phone,
        dob: user.dob,
        gender: user.gender,
        country: user.country,
        loggedIn: user.loggedIn,
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
        tokenExpiry: user.tokenExpiry,
        isSynced: user.isSynced,
        createdAt: user.createdAt ?? DateTime.now(),
        updatedAt: user.updatedAt ?? DateTime.now(),
      );
      await usersBox.put(userCopy.id, userCopy);
      _logger.info('User [${user.name}] saved successfully to Hive.');
    } catch (e, stackTrace) {
      _logger.severe(
        'Error saving user [${user.name}]: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> validateUser(String emailOrPhone, String password) async {
    final usersBox = getUserBox();
    // todo: comment after development
    final hbox = getUserBox();
// Get all data as a list:
    List allData = hbox.keys.map((key) {
      final value = hbox.get(key);
      return { "key": key, "value": value };
    }).toList();
    print("users allData");
    print(allData);
    final hashedPassword = PasswordUtils.hashPassword(password);
    AppUser? user = usersBox.values.firstWhere(
      (u) =>
          (u.email == emailOrPhone || u.phone == emailOrPhone) &&
          u.passwordHash == hashedPassword,
      orElse:
          () =>
              throw ("Invalid credentials"), // This works only if UserModel? user
    );

    user.loggedIn = true;
    await user.save();
  }

  static Future<void> logout() async {
    final box = getUserBox();
    for (final user in box.values) {
      if (user.loggedIn) {
        user.loggedIn = false;
        await user.save(); // Save updated state
      }
    }
    /// todo: comment after development
    final hbox = Hive.box('userBoxName');
    // Get all data as a list:
    List allData = hbox.keys.map((key) {
      final value = hbox.get(key);
      return { "key": key, "value": value };
    }).toList();
    print(allData);

    final googleService = GoogleSignInService();
    await googleService.signOut();
    _logger.info('User logged out successfully.');
  }

  static AppUser? getLoggedInUser() {
    final box = getUserBox();
    final loggedInUsers = box.values.where((user) => user.loggedIn);
    return loggedInUsers.isNotEmpty ? loggedInUsers.first : null;
  }

  static Future<bool> isLoggedIn() async {
    final box = getUserBox();
    return box.values.any((user) => user.loggedIn);
  }
}
