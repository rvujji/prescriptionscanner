// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrescriptionAdapter extends TypeAdapter<Prescription> {
  @override
  final int typeId = 0;

  @override
  Prescription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Prescription(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      patientName: fields[2] as String,
      doctorName: fields[3] as String,
      medications: (fields[4] as List).cast<Medication>(),
      notes: fields[5] as String,
      imagePath: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Prescription obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.patientName)
      ..writeByte(3)
      ..write(obj.doctorName)
      ..writeByte(4)
      ..write(obj.medications)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prescription _$PrescriptionFromJson(Map<String, dynamic> json) => Prescription(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      patientName: json['patient_name'] as String,
      doctorName: json['doctor_name'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String,
      imagePath: json['imagePath'] as String,
    );

Map<String, dynamic> _$PrescriptionToJson(Prescription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'patient_name': instance.patientName,
      'doctor_name': instance.doctorName,
      'medications': instance.medications,
      'notes': instance.notes,
      'imagePath': instance.imagePath,
    };
