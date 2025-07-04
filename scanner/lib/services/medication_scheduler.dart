import 'package:hive/hive.dart';
import 'notification_service.dart';
import '../models/prescription.dart';

class MedicationScheduler {
  final NotificationService _notificationService = NotificationService();
  final Box<Prescription> _prescriptionsBox;

  MedicationScheduler(this._prescriptionsBox);

  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  Future<void> scheduleAllMedications() async {
    // Clear existing notifications
    await _notificationService.cancelAllNotifications();

    // Get all prescriptions
    final prescriptions = _prescriptionsBox.values.toList();

    // Generate unique IDs for notifications
    var notificationId = 0;

    for (final prescription in prescriptions) {
      for (final medication in prescription.medications) {
        // Schedule each administration time
        for (final adminTime in medication.times) {
          final scheduledTimes = adminTime.getAllScheduledTimes(
            prescription.date,
            medication.duration,
          );

          for (final scheduledTime in scheduledTimes) {
            // Skip past notifications
            if (scheduledTime.isBefore(DateTime.now())) continue;

            await _notificationService.scheduleMedicationNotification(
              id: notificationId++,
              title: 'Time to take ${medication.name}',
              body:
                  'Take ${medication.dosage.quantity} '
                  '${medication.dosage.unit.name} as prescribed',
              scheduledTime: scheduledTime,
            );
          }
        }
      }
    }
  }

  Future<void> rescheduleMedicationsForPrescription(
    String prescriptionId,
  ) async {
    final prescription = _prescriptionsBox.get(prescriptionId);
    if (prescription == null) return;

    // First cancel all notifications for this prescription
    await _cancelNotificationsForPrescription(prescriptionId);

    // Then reschedule them
    var notificationId = _getBaseNotificationId(prescriptionId);

    for (final medication in prescription.medications) {
      for (final adminTime in medication.times) {
        final scheduledTimes = adminTime.getAllScheduledTimes(
          prescription.date,
          medication.duration,
        );

        for (final scheduledTime in scheduledTimes) {
          // Skip past notifications
          if (scheduledTime.isBefore(DateTime.now())) continue;

          await _notificationService.scheduleMedicationNotification(
            id: notificationId++,
            title: 'Time to take ${medication.name}',
            body:
                'Take ${medication.dosage.quantity} '
                '${medication.dosage.unit.name} as prescribed',
            scheduledTime: scheduledTime,
          );
        }
      }
    }
  }

  Future<void> _cancelNotificationsForPrescription(
    String prescriptionId,
  ) async {
    final baseId = _getBaseNotificationId(prescriptionId);
    // Assuming max 100 medications per prescription
    for (var i = 0; i < 100; i++) {
      await _notificationService.cancelNotification(baseId + i);
    }
  }

  int _getBaseNotificationId(String prescriptionId) {
    // Generate a base ID from the prescription ID hash
    return prescriptionId.hashCode % 100000;
  }
}
