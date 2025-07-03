import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'medication.dart'; // Import your Medication model

part 'prescription.g.dart'; // For Hive TypeAdapter

@HiveType(typeId: 0) // Unique ID for Hive (must be different from Medication)
@JsonSerializable() // Annotation for JSON serialization
class Prescription extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id') // Optional: if JSON key differs from Dart field name
  String id; // Use String for server IDs

  @HiveField(1)
  @JsonKey(name: 'date')
  DateTime date; // json_serializable handles DateTime to ISO 8601 string and back

  @HiveField(2)
  @JsonKey(name: 'patient_name') // Example: JSON key might be snake_case
  String patientName;

  @HiveField(3)
  @JsonKey(name: 'doctor_name')
  String doctorName;

  @HiveField(4)
  @JsonKey(name: 'medications')
  List<Medication> medications; // json_serializable automatically handles nested @JsonSerializable classes

  @HiveField(5)
  @JsonKey(name: 'notes')
  String notes;

  @HiveField(6)
  // imagePath is typically a local file path.
  // For the server, you would upload the image separately and store a URL.
  // So, you might NOT want to send this field directly in the JSON.
  // If you want to omit it from JSON, use @JsonKey(ignore: true)
  // If you want to send it but expect a URL from server, consider a separate field for URL.
  String imagePath;

  Prescription({
    required this.id,
    required this.date,
    required this.patientName,
    required this.doctorName,
    required this.medications,
    required this.notes,
    required this.imagePath,
  });

  // --- JSON Serialization Methods ---
  // A factory constructor to create a Prescription from a JSON map
  factory Prescription.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionFromJson(json);

  // A method to convert a Prescription object to a JSON map
  Map<String, dynamic> toJson() => _$PrescriptionToJson(this);

  Prescription copyWith({
    String? id,
    DateTime? date,
    String? patientName,
    String? doctorName,
    List<Medication>? medications,
    String? notes,
    String? imagePath,
  }) {
    return Prescription(
      id: id ?? this.id,
      date: date ?? this.date,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
