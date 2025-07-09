import 'package:hive/hive.dart';
import 'notification_service.dart';
import '../models/prescription.dart';
import 'dart:developer' as developer;
import '../utilities/alarms_info.dart';

class MedicationScheduler {
  final NotificationService _notificationService = NotificationService();
  final Box<Prescription> _prescriptionsBox;
  final String _logTag = 'MedicationScheduler';

  MedicationScheduler(this._prescriptionsBox);

  Future<void> initialize() async {
    try {
      developer.log('Initializing MedicationScheduler...', name: _logTag);
      await _notificationService.initialize();
      developer.log('Initialized successfully', name: _logTag);
    } catch (e, stackTrace) {
      developer.log(
        'Initialization failed: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> scheduleAllMedications() async {
    try {
      developer.log('Scheduling all medications...', name: _logTag);
      await _notificationService.cancelAllNotifications();

      final prescriptions = _prescriptionsBox.values.toList();
      developer.log(
        'Found ${prescriptions.length} prescriptions',
        name: _logTag,
      );

      int totalScheduled = 0;

      for (final prescription in prescriptions) {
        for (final medication in prescription.medications) {
          final baseId = _getBaseNotificationId(prescription.id, medication.id);
          int notificationId = baseId;

          for (final adminTime in medication.times) {
            final scheduledTimes = adminTime.getAllScheduledTimes(
              prescription.date,
              medication.duration,
            );
            for (final scheduledTime in scheduledTimes) {
              if (scheduledTime.isBefore(DateTime.now())) continue;

              await _notificationService.scheduleMedicationNotification(
                id: notificationId++,
                title: 'Time to take ${medication.name}',
                body:
                    'Take ${medication.dosage.quantity} ${medication.dosage.unit.name}',
                scheduledTime: scheduledTime,
                isForever: medication.duration.isForever,
              );

              // developer.log(
              //   'Scheduled: prescription=${prescription.id}, medication=${medication.id}, time=$scheduledTime, id=${notificationId - 1}',
              //   name: _logTag,
              // );

              totalScheduled++;
            }
          }
        }
      }

      developer.log(
        'Total scheduled notifications: $totalScheduled',
        name: _logTag,
      );
      checkScheduledNotifications();
    } catch (e, stackTrace) {
      developer.log(
        'Scheduling failed: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> rescheduleMedicationsForPrescription(
    String prescriptionId,
  ) async {
    try {
      developer.log(
        'Rescheduling for prescription: $prescriptionId',
        name: _logTag,
      );
      final prescription = _prescriptionsBox.get(prescriptionId);
      if (prescription == null) {
        developer.log('Prescription not found: $prescriptionId', name: _logTag);
        return;
      }

      await _cancelNotificationsForPrescription(prescription);

      int totalRescheduled = 0;

      for (final medication in prescription.medications) {
        final baseId = _getBaseNotificationId(prescription.id, medication.id);
        int notificationId = baseId;

        for (final adminTime in medication.times) {
          final scheduledTimes = adminTime.getAllScheduledTimes(
            prescription.date,
            medication.duration,
          );
          for (final scheduledTime in scheduledTimes) {
            if (scheduledTime.isBefore(DateTime.now())) continue;

            await _notificationService.scheduleMedicationNotification(
              id: notificationId++,
              title: 'Time to take ${medication.name}',
              body:
                  'Take ${medication.dosage.quantity} ${medication.dosage.unit.name}',
              scheduledTime: scheduledTime,
              isForever: medication.duration.isForever,
            );

            developer.log(
              'Rescheduled: prescription=${prescription.id}, medication=${medication.id}, time=$scheduledTime, id=${notificationId - 1}',
              name: _logTag,
            );

            totalRescheduled++;
          }
        }
      }

      developer.log('Total rescheduled: $totalRescheduled', name: _logTag);
    } catch (e, stackTrace) {
      developer.log(
        'Rescheduling failed: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _cancelNotificationsForPrescription(
    Prescription prescription,
  ) async {
    try {
      int totalCancelled = 0;

      for (final medication in prescription.medications) {
        final baseId = _getBaseNotificationId(prescription.id, medication.id);
        for (var i = 0; i < 100; i++) {
          final id = baseId + i;
          try {
            await _notificationService.cancelNotification(id);
            totalCancelled++;
          } catch (e) {
            developer.log('Failed to cancel ID $id: $e', name: _logTag);
          }
        }
      }

      developer.log(
        'Cancelled $totalCancelled notifications for prescription ${prescription.id}',
        name: _logTag,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Cancel failed: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> scheduleMedicationsForPrescription(
    Prescription prescription,
  ) async {
    try {
      developer.log(
        'Scheduling updated prescription: ${prescription.id}',
        name: _logTag,
      );

      // Cancel existing notifications for this prescription
      await _cancelNotificationsForPrescription(prescription);

      int totalScheduled = 0;

      for (final medication in prescription.medications) {
        final baseId = _getBaseNotificationId(prescription.id, medication.id);
        int notificationId = baseId;

        for (final adminTime in medication.times) {
          final scheduledTimes = adminTime.getAllScheduledTimes(
            prescription.date,
            medication.duration,
          );

          for (final scheduledTime in scheduledTimes) {
            if (scheduledTime.isBefore(DateTime.now())) continue;

            await _notificationService.scheduleMedicationNotification(
              id: notificationId++,
              title: 'Time to take ${medication.name}',
              body:
                  'Take ${medication.dosage.quantity} ${medication.dosage.unit.name}',
              scheduledTime: scheduledTime,
              isForever: medication.duration.isForever,
            );

            developer.log(
              'Scheduled: prescription=${prescription.id}, medication=${medication.id}, time=$scheduledTime, id=${notificationId - 1}',
              name: _logTag,
            );

            totalScheduled++;
          }
        }
      }

      developer.log(
        'Total newly scheduled notifications: $totalScheduled',
        name: _logTag,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Scheduling updated prescription failed: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Creates a base ID using a combined hash of prescription and medication IDs.
  int _getBaseNotificationId(String prescriptionId, String medicationId) {
    return (prescriptionId + medicationId).hashCode.abs() % 1000000;
  }
}
