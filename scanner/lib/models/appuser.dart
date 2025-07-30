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
  @JsonKey(name: 'passwordhash')
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
  @JsonKey(name: 'loggedin')
  bool loggedIn;

  @HiveField(9)
  @JsonKey(name: 'accesstoken')
  String? accessToken;

  @HiveField(10)
  @JsonKey(name: 'refreshtoken')
  String? refreshToken;

  @HiveField(11)
  @JsonKey(name: 'tokenexpiry')
  DateTime? tokenExpiry;

  @HiveField(12)
  @JsonKey(name: 'issynced')
  bool isSynced;

  @HiveField(13)
  @JsonKey(name: 'createdat')
  DateTime? createdAt;

  @HiveField(14)
  @JsonKey(name: 'updatedat')
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

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
    DateTime? dob,
    String? gender,
    String? country,
    bool? loggedIn,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      loggedIn: loggedIn ?? this.loggedIn,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
