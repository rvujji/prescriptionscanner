import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medication.g.dart'; // For generated code

@HiveType(typeId: 1)
@JsonSerializable()
class Medication {
  @HiveField(0)
  String name;

  @HiveField(1)
  Dosage dosage;

  @HiveField(2)
  List<AdministrationTime> times;

  @HiveField(3)
  String duration;

  Medication({
    required this.name,
    required this.dosage,
    required this.times,
    required this.duration,
  });

  // JSON Serialization
  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationToJson(this);

  // Copy method
  Medication copyWith({
    String? name,
    Dosage? dosage,
    List<AdministrationTime>? times,
    String? duration,
  }) {
    return Medication(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? List.from(this.times),
      duration: duration ?? this.duration,
    );
  }

  // Formatting method
  String format() {
    final dosageStr =
        dosage.unit == DosageUnit.other
            ? '${dosage.quantity} ${dosage.customUnit}'
            : '${dosage.quantity} ${dosage.unit.name}';

    final timesStr = times
        .map((t) {
          return '${t.frequency}×/${t.unit.name}${t.specificTimes != null ? ' at ${t.specificTimes}' : ''}';
        })
        .join(', ');

    return '$name ($dosageStr, $timesStr, for $duration)';
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
  final String? specificTimes;

  AdministrationTime({
    required this.frequency,
    required this.unit,
    this.specificTimes,
  });

  factory AdministrationTime.fromJson(Map<String, dynamic> json) =>
      _$AdministrationTimeFromJson(json);
  Map<String, dynamic> toJson() => _$AdministrationTimeToJson(this);

  AdministrationTime copyWith({
    int? frequency,
    TimeUnit? unit,
    String? specificTimes,
  }) {
    return AdministrationTime(
      frequency: frequency ?? this.frequency,
      unit: unit ?? this.unit,
      specificTimes: specificTimes ?? this.specificTimes,
    );
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
