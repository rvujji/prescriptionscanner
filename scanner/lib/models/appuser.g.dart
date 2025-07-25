// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appuser.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 8;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      passwordHash: fields[3] as String,
      phone: fields[4] as String,
      dob: fields[5] as DateTime,
      gender: fields[6] as String,
      country: fields[7] as String,
      loggedIn: fields[8] as bool,
      accessToken: fields[9] as String?,
      refreshToken: fields[10] as String?,
      tokenExpiry: fields[11] as DateTime?,
      isSynced: fields[12] as bool,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.passwordHash)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.dob)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.country)
      ..writeByte(8)
      ..write(obj.loggedIn)
      ..writeByte(9)
      ..write(obj.accessToken)
      ..writeByte(10)
      ..write(obj.refreshToken)
      ..writeByte(11)
      ..write(obj.tokenExpiry)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordhash'] as String,
      phone: json['phone'] as String,
      dob: DateTime.parse(json['dob'] as String),
      gender: json['gender'] as String,
      country: json['country'] as String,
      loggedIn: json['loggedin'] as bool,
      accessToken: json['accesstoken'] as String?,
      refreshToken: json['refreshtoken'] as String?,
      tokenExpiry: json['tokenexpiry'] == null
          ? null
          : DateTime.parse(json['tokenexpiry'] as String),
      isSynced: json['issynced'] as bool? ?? false,
      createdAt: json['createdat'] == null
          ? null
          : DateTime.parse(json['createdat'] as String),
      updatedAt: json['updatedat'] == null
          ? null
          : DateTime.parse(json['updatedat'] as String),
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'passwordhash': instance.passwordHash,
      'phone': instance.phone,
      'dob': instance.dob.toIso8601String(),
      'gender': instance.gender,
      'country': instance.country,
      'loggedin': instance.loggedIn,
      'accesstoken': instance.accessToken,
      'refreshtoken': instance.refreshToken,
      'tokenexpiry': instance.tokenExpiry?.toIso8601String(),
      'issynced': instance.isSynced,
      'createdat': instance.createdAt?.toIso8601String(),
      'updatedat': instance.updatedAt?.toIso8601String(),
    };
