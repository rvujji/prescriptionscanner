import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appuser.g.dart';

@HiveType(typeId: 8)
@JsonSerializable()
class AppUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String passwordHash;

  @HiveField(4)
  String phone;

  @HiveField(5)
  DateTime dob;

  @HiveField(6)
  String gender;

  @HiveField(7)
  String country;

  @HiveField(8)
  bool loggedIn;

  @HiveField(9)
  String? accessToken;

  @HiveField(10)
  String? refreshToken;

  @HiveField(11)
  DateTime? tokenExpiry;

  @HiveField(12)
  bool isSynced;

  @HiveField(13)
  DateTime? createdAt;

  @HiveField(14)
  DateTime? updatedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.country,
    required this.loggedIn,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiry,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}
