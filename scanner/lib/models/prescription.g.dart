// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrescriptionAdapter extends TypeAdapter<Prescription> {
  @override
  final int typeId = 7;

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
      userId: fields[7] as String,
      isSynced: fields[8] as bool,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Prescription obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
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
      patientName: json['patientName'] as String,
      doctorName: json['doctorName'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String,
      imagePath: json['imagePath'] as String,
      userId: json['userId'] as String,
      isSynced: json['isSynced'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PrescriptionToJson(Prescription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'patientName': instance.patientName,
      'doctorName': instance.doctorName,
      'medications': instance.medications,
      'notes': instance.notes,
      'imagePath': instance.imagePath,
      'userId': instance.userId,
      'isSynced': instance.isSynced,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
