import 'package:dio/dio.dart';
import '../models/appuser.dart';
import 'hive_service.dart';
import 'postgreslocal_service.dart';
import '../utils/password_utils.dart';

class AuthService {
  final Dio _dio = PostgresLocalService().client;

  Future<AppUser?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordHash,
    required DateTime dob,
    required String gender,
    required String country,
  }) async {
    try {
      print("📤 Calling /rpc/register_user with payload...");

      final response = await _dio.post(
        '/rpc/register_user',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'pwd': password, // raw password → DB hashes it
          'dob': dob.toIso8601String(),
          'gender': gender,
          'country': country,
        },
      );

      print("📥 Response from PostgREST: ${response.data}");

      final newUserId = response.data?.toString();
      if (newUserId == null || newUserId.isEmpty) {
        print('❌ Registration failed: No user ID returned.');
        return null;
      }

      final newUser = AppUser(
        id: newUserId,
        name: name,
        email: email,
        passwordHash: PasswordUtils.hashPassword(password);,
        phone: phone,
        dob: dob,
        gender: gender,
        country: country,
        loggedIn: false,
        isSynced: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await HiveService.saveRegisteredUserToHive(newUser);
      print('✅ User successfully registered and saved to Hive.');

      return newUser;
    } on DioException catch (e) {
      if (e.response != null) {
        print('❌ Registration error (PostgREST): ${e.response!.data}');
      } else {
        print('❌ Dio error: ${e.message}');
      }
      return null;
    } catch (e) {
      print('❌ Unexpected error: $e');
      return null;
    }
  }
}
