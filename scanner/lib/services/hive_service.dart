import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import '../models/prescription.dart';
import '../models/medication.dart';
import '../models/user.dart';
import 'medication_scheduler.dart';

final Logger _logger = Logger('HiveService');

class HiveService {
  static const String _prescriptionBoxName = 'prescriptions';
  static const String _userBoxName = 'users';

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
      Hive.registerAdapter(UserAdapter());

      await Hive.openBox<Prescription>(_prescriptionBoxName);
      await Hive.openBox<User>(_userBoxName);
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
                frontImagePath: m.frontImagePath,
                backImagePath: m.backImagePath,
              );
            }).toList(),
        notes: prescription.notes,
        imagePath: prescription.imagePath,
      );

      await box.put(prescriptionCopy.id, prescriptionCopy);
      final medicationScheduler = MedicationScheduler(getPrescriptionBox());
      await medicationScheduler.scheduleMedicationsForPrescription(
        prescriptionCopy,
      );

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

  static Box<User> getUserBox() {
    return Hive.box<User>(_userBoxName);
  }

  static Future<void> saveUser(User user) async {
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
      final userCopy = User(
        name: user.name,
        email: user.email,
        phone: user.phone,
        password: user.password,
        dob: user.dob,
        loggedIn: user.loggedIn,
      );
      await usersBox.put(userCopy.email, userCopy);
      _logger.info('User [${user.name}] saved successfully.');
    } catch (e, stackTrace) {
      _logger.severe(
        'Error saving prescription [${user.name}]: $e',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> validateUser(String emailOrPhone, String password) async {
    final usersBox = Hive.box<User>('users');

    User? user = usersBox.values.firstWhere(
      (u) =>
          (u.email == emailOrPhone || u.phone == emailOrPhone) &&
          u.password == password,
      orElse: () => null as User, // This works only if UserModel? user
    );

    if (user == null) {
      throw ("Invalid credentials");
    }
    user.loggedIn = true;
    await user.save();
  }

  static Future<void> logout() async {
    final box = Hive.box<User>('users');
    for (final user in box.values) {
      if (user.loggedIn) {
        user.loggedIn = false;
        await user.save(); // Save updated state
      }
    }
  }

  User? getLoggedInUser() {
    final box = Hive.box<User>('users');
    return box.values.firstWhere(
      (user) => user.loggedIn,
      orElse: () => null as User,
    );
  }

  static Future<bool> isLoggedIn() async {
    final box = Hive.box<User>(_userBoxName);
    return box.values.any((user) => user.loggedIn);
  }
}
