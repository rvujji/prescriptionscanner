import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'medication.dart'; // Import your Medication model

part 'prescription.g.dart'; // For Hive TypeAdapter

@HiveType(typeId: 7) // Unique ID for Hive (must be different from Medication)
@JsonSerializable()
class Prescription extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  String id;

  @HiveField(1)
  @JsonKey(name: 'date')
  DateTime date;

  @HiveField(2)
  @JsonKey(name: 'patient_name')
  String patientName;

  @HiveField(3)
  @JsonKey(name: 'doctor_name')
  String doctorName;

  @HiveField(4)
  @JsonKey(name: 'medications')
  List<Medication> medications;

  @HiveField(5)
  @JsonKey(name: 'notes')
  String notes;

  @HiveField(6)
  String imagePath;

  @HiveField(7)
  @JsonKey(name: 'userEmail')
  String userEmail;

  Prescription({
    required this.id,
    required this.date,
    required this.patientName,
    required this.doctorName,
    required this.medications,
    required this.notes,
    required this.imagePath,
    required this.userEmail, // Add to constructor
  });

  factory Prescription.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionFromJson(json);

  Map<String, dynamic> toJson() => _$PrescriptionToJson(this);

  Prescription copyWith({
    String? id,
    DateTime? date,
    String? patientName,
    String? doctorName,
    List<Medication>? medications,
    String? notes,
    String? imagePath,
    String? userEmail, // Add here
  }) {
    return Prescription(
      id: id ?? this.id,
      date: date ?? this.date,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
