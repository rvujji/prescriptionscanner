import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medication.g.dart'; // For Hive TypeAdapter

@HiveType(typeId: 1) // Unique ID for Hive
@JsonSerializable() // Annotation for JSON serialization
class Medication {
  @HiveField(0)
  @JsonKey(name: 'name') // Optional: if JSON key differs from Dart field name
  String name;

  @HiveField(1)
  @JsonKey(name: 'dosage')
  String dosage;

  @HiveField(2)
  @JsonKey(name: 'frequency')
  String frequency;

  @HiveField(3)
  @JsonKey(name: 'duration')
  String duration;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  // --- JSON Serialization Methods ---
  // A factory constructor to create a Medication from a JSON map
  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);

  // A method to convert a Medication object to a JSON map
  Map<String, dynamic> toJson() => _$MedicationToJson(this);

  Medication copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
  }) {
    return Medication(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
    );
  }
}
