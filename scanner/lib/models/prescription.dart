import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'medication.dart';
import 'package:uuid/uuid.dart';

part 'prescription.g.dart'; // For Hive TypeAdapter

@HiveType(typeId: 7) // Unique ID for Hive (must be different from Medication)
@JsonSerializable()
class Prescription extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  @JsonKey(name: 'patientname')
  String patientName;

  @HiveField(3)
  @JsonKey(name: 'doctorname')
  String doctorName;

  @HiveField(4)
  List<Medication> medications;

  @HiveField(5)
  String notes;

  @HiveField(6)
  @JsonKey(name: 'imagepath')
  String imagePath;

  @HiveField(7)
  @JsonKey(name: 'userid')
  String userId;

  @HiveField(8)
  @JsonKey(name: 'issynced')
  bool isSynced;

  @HiveField(9)
  @JsonKey(name: 'createdat')
  DateTime? createdAt;

  @HiveField(10)
  @JsonKey(name: 'updatedat')
  DateTime? updatedAt;

  Prescription({
    String? id,
    required this.date,
    required this.patientName,
    required this.doctorName,
    required this.medications,
    required this.notes,
    required this.imagePath,
    required this.userId,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

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
    String? userId,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prescription(
      id: id ?? this.id,
      date: date ?? this.date,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
