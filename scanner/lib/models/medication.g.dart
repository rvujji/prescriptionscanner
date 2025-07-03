// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 1;

  @override
  Medication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medication(
      name: fields[0] as String,
      dosage: fields[1] as Dosage,
      times: (fields[2] as List).cast<AdministrationTime>(),
      duration: fields[3] as DurationPeriod,
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dosage)
      ..writeByte(2)
      ..write(obj.times)
      ..writeByte(3)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DosageAdapter extends TypeAdapter<Dosage> {
  @override
  final int typeId = 2;

  @override
  Dosage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dosage(
      quantity: fields[0] as double,
      unit: fields[1] as DosageUnit,
      customUnit: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Dosage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.quantity)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.customUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DosageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdministrationTimeAdapter extends TypeAdapter<AdministrationTime> {
  @override
  final int typeId = 3;

  @override
  AdministrationTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdministrationTime(
      frequency: fields[0] as int,
      unit: fields[1] as TimeUnit,
      specificTimes: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AdministrationTime obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.frequency)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.specificTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdministrationTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DurationPeriodAdapter extends TypeAdapter<DurationPeriod> {
  @override
  final int typeId = 6;

  @override
  DurationPeriod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DurationPeriod(
      number: fields[0] as int?,
      unit: fields[1] as TimeUnit?,
    );
  }

  @override
  void write(BinaryWriter writer, DurationPeriod obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DosageUnitAdapter extends TypeAdapter<DosageUnit> {
  @override
  final int typeId = 4;

  @override
  DosageUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DosageUnit.milligram;
      case 1:
        return DosageUnit.gram;
      case 2:
        return DosageUnit.milliliter;
      case 3:
        return DosageUnit.liter;
      case 4:
        return DosageUnit.drop;
      case 5:
        return DosageUnit.tablet;
      case 6:
        return DosageUnit.capsule;
      case 7:
        return DosageUnit.puff;
      case 8:
        return DosageUnit.other;
      default:
        return DosageUnit.milligram;
    }
  }

  @override
  void write(BinaryWriter writer, DosageUnit obj) {
    switch (obj) {
      case DosageUnit.milligram:
        writer.writeByte(0);
        break;
      case DosageUnit.gram:
        writer.writeByte(1);
        break;
      case DosageUnit.milliliter:
        writer.writeByte(2);
        break;
      case DosageUnit.liter:
        writer.writeByte(3);
        break;
      case DosageUnit.drop:
        writer.writeByte(4);
        break;
      case DosageUnit.tablet:
        writer.writeByte(5);
        break;
      case DosageUnit.capsule:
        writer.writeByte(6);
        break;
      case DosageUnit.puff:
        writer.writeByte(7);
        break;
      case DosageUnit.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DosageUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeUnitAdapter extends TypeAdapter<TimeUnit> {
  @override
  final int typeId = 5;

  @override
  TimeUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TimeUnit.hour;
      case 1:
        return TimeUnit.day;
      case 2:
        return TimeUnit.week;
      case 3:
        return TimeUnit.month;
      default:
        return TimeUnit.hour;
    }
  }

  @override
  void write(BinaryWriter writer, TimeUnit obj) {
    switch (obj) {
      case TimeUnit.hour:
        writer.writeByte(0);
        break;
      case TimeUnit.day:
        writer.writeByte(1);
        break;
      case TimeUnit.week:
        writer.writeByte(2);
        break;
      case TimeUnit.month:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Medication _$MedicationFromJson(Map<String, dynamic> json) => Medication(
      name: json['name'] as String,
      dosage: Dosage.fromJson(json['dosage'] as Map<String, dynamic>),
      times: (json['times'] as List<dynamic>)
          .map((e) => AdministrationTime.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration:
          DurationPeriod.fromJson(json['duration'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MedicationToJson(Medication instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dosage': instance.dosage,
      'times': instance.times,
      'duration': instance.duration,
    };

Dosage _$DosageFromJson(Map<String, dynamic> json) => Dosage(
      quantity: (json['quantity'] as num).toDouble(),
      unit: $enumDecode(_$DosageUnitEnumMap, json['unit']),
      customUnit: json['customUnit'] as String?,
    );

Map<String, dynamic> _$DosageToJson(Dosage instance) => <String, dynamic>{
      'quantity': instance.quantity,
      'unit': _$DosageUnitEnumMap[instance.unit]!,
      'customUnit': instance.customUnit,
    };

const _$DosageUnitEnumMap = {
  DosageUnit.milligram: 'milligram',
  DosageUnit.gram: 'gram',
  DosageUnit.milliliter: 'milliliter',
  DosageUnit.liter: 'liter',
  DosageUnit.drop: 'drop',
  DosageUnit.tablet: 'tablet',
  DosageUnit.capsule: 'capsule',
  DosageUnit.puff: 'puff',
  DosageUnit.other: 'other',
};

AdministrationTime _$AdministrationTimeFromJson(Map<String, dynamic> json) =>
    AdministrationTime(
      frequency: (json['frequency'] as num).toInt(),
      unit: $enumDecode(_$TimeUnitEnumMap, json['unit']),
      specificTimes: (json['specificTimes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AdministrationTimeToJson(AdministrationTime instance) =>
    <String, dynamic>{
      'frequency': instance.frequency,
      'unit': _$TimeUnitEnumMap[instance.unit]!,
      'specificTimes': instance.specificTimes,
    };

const _$TimeUnitEnumMap = {
  TimeUnit.hour: 'hour',
  TimeUnit.day: 'day',
  TimeUnit.week: 'week',
  TimeUnit.month: 'month',
};

DurationPeriod _$DurationPeriodFromJson(Map<String, dynamic> json) =>
    DurationPeriod(
      number: (json['number'] as num?)?.toInt(),
      unit: $enumDecodeNullable(_$TimeUnitEnumMap, json['unit']),
    );

Map<String, dynamic> _$DurationPeriodToJson(DurationPeriod instance) =>
    <String, dynamic>{
      'number': instance.number,
      'unit': _$TimeUnitEnumMap[instance.unit],
    };
