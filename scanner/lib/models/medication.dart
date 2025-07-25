import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
part 'medication.g.dart'; // For generated code

@HiveType(typeId: 1)
@JsonSerializable()
class Medication {
  @HiveField(0)
  final String id; // Add this field

  @HiveField(1)
  String name;

  @HiveField(2) // Update field indices
  Dosage dosage;

  @HiveField(3)
  List<AdministrationTime> times;

  @HiveField(4)
  DurationPeriod duration;

  @HiveField(5)
  String? frontImagePath;

  @HiveField(6)
  String? backImagePath;

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  DateTime? createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  Medication({
    String? id, // Make optional for creation
    required this.name,
    required this.dosage,
    required this.times,
    required this.duration,
    this.frontImagePath,
    this.backImagePath,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(); // Generate ID if not provided

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationToJson(this);

  Medication copyWith({
    String? id,
    String? name,
    Dosage? dosage,
    List<AdministrationTime>? times,
    DurationPeriod? duration,
    String? frontImagePath,
    String? backImagePath,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id, // Include ID in copyWith
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? List.from(this.times),
      duration: duration ?? this.duration,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String format() {
    final dosageStr =
        dosage.unit == DosageUnit.other
            ? '${dosage.quantity} ${dosage.customUnit}'
            : '${dosage.quantity} ${dosage.unit.name}';

    final timesStr = times
        .map(
          (t) =>
              '${t.frequency}/${t.unit.name} at ${t.specificTimes.join(', ')}',
        )
        .join(', ');

    return '$name ($dosageStr, $timesStr, for ${duration.format()})';
  }
}

@HiveType(typeId: 2)
@JsonSerializable()
class Dosage {
  @HiveField(0)
  final double quantity;

  @HiveField(1)
  final DosageUnit unit;

  @HiveField(2)
  final String? customUnit;

  Dosage({required this.quantity, required this.unit, this.customUnit});

  factory Dosage.fromJson(Map<String, dynamic> json) => _$DosageFromJson(json);
  Map<String, dynamic> toJson() => _$DosageToJson(this);

  Dosage copyWith({double? quantity, DosageUnit? unit, String? customUnit}) {
    return Dosage(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      customUnit: customUnit ?? this.customUnit,
    );
  }
}

@HiveType(typeId: 3)
@JsonSerializable()
class AdministrationTime {
  @HiveField(0)
  final int frequency;

  @HiveField(1)
  final TimeUnit unit;

  @HiveField(2)
  final List<String> specificTimes;

  AdministrationTime({
    required this.frequency,
    required this.unit,
    required this.specificTimes,
  });

  factory AdministrationTime.fromJson(Map<String, dynamic> json) =>
      _$AdministrationTimeFromJson(json);
  Map<String, dynamic> toJson() => _$AdministrationTimeToJson(this);

  AdministrationTime copyWith({
    int? frequency,
    TimeUnit? unit,
    List<String>? specificTimes,
  }) {
    return AdministrationTime(
      frequency: frequency ?? this.frequency,
      unit: unit ?? this.unit,
      specificTimes: specificTimes ?? this.specificTimes,
    );
  }

  List<DateTime> getAllScheduledTimes(
    DateTime startDate,
    DurationPeriod duration,
  ) {
    final times = <DateTime>[];
    final now = DateTime.now();

    if (duration.isForever) {
      // For "forever" duration, only return today's or tomorrow's times
      final todayTimes = _getTimesForDate(now);
      final isPastAllTimesToday = todayTimes.every(
        (time) => time.isBefore(now),
      );

      if (isPastAllTimesToday) {
        // If all times today have passed, return tomorrow's times
        times.addAll(_getTimesForDate(now.add(const Duration(days: 1))));
      } else {
        // Otherwise return today's upcoming times
        times.addAll(todayTimes.where((time) => time.isAfter(now)));
      }
    } else {
      final durationMinutes = duration.inMinutes;
      final endDate =
          durationMinutes != null
              ? startDate.add(Duration(minutes: durationMinutes))
              : DateTime.now().add(const Duration(days: 365 * 10));

      var currentDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      while (currentDate.isBefore(endDate)) {
        for (final timeStr in specificTimes) {
          final timeParts = timeStr.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
          times.add(
            DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
              hour,
              minute,
            ),
          );
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return times;
  }

  // Helper method to get times for a specific date
  List<DateTime> _getTimesForDate(DateTime date) {
    return specificTimes.map((timeStr) {
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    }).toList();
  }
}

@HiveType(typeId: 4)
enum DosageUnit {
  @HiveField(0)
  milligram,
  @HiveField(1)
  gram,
  @HiveField(2)
  milliliter,
  @HiveField(3)
  liter,
  @HiveField(4)
  drop,
  @HiveField(5)
  tablet,
  @HiveField(6)
  capsule,
  @HiveField(7)
  puff,
  @HiveField(8)
  other,
}

@HiveType(typeId: 5)
enum TimeUnit {
  @HiveField(0)
  hour,
  @HiveField(1)
  day,
  @HiveField(2)
  week,
  @HiveField(3)
  month,
}

@HiveType(typeId: 6)
@JsonSerializable()
class DurationPeriod {
  @HiveField(0)
  final int? number;

  @HiveField(1)
  final TimeUnit? unit;

  DurationPeriod({this.number, this.unit});

  factory DurationPeriod.forever() => DurationPeriod(number: null, unit: null);

  bool get isForever => number == null || unit == null;

  String format() =>
      isForever ? 'forever' : '$number ${unit!.name}${number! > 1 ? 's' : ''}';

  factory DurationPeriod.fromJson(Map<String, dynamic> json) =>
      _$DurationPeriodFromJson(json);
  Map<String, dynamic> toJson() => _$DurationPeriodToJson(this);
}

extension DurationPeriodExtension on DurationPeriod {
  int? get inMinutes {
    if (isForever) return null;
    switch (unit) {
      case TimeUnit.hour:
        return number! * 60;
      case TimeUnit.day:
        return number! * 24 * 60;
      case TimeUnit.week:
        return number! * 7 * 24 * 60;
      case TimeUnit.month:
        return number! * 30 * 24 * 60;
      default:
        return null;
    }
  }
}

extension AdministrationTimeExtension on AdministrationTime {
  List<DateTime> getTodayTimes() {
    final now = DateTime.now();
    return specificTimes.map((timeStr) {
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      return DateTime(now.year, now.month, now.day, hour, minute);
    }).toList();
  }
}
