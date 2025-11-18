import 'package:dio/dio.dart';
import 'database_service.dart';

class PostgresLocalService implements DatabaseService<Dio> {
  static final PostgresLocalService _instance = PostgresLocalService._internal();
  factory PostgresLocalService() => _instance;

  Dio? _dio;

  PostgresLocalService._internal();

  static const String _baseUrl = 'http://10.0.2.2:3000';

  @override
  Future<void> initialize() async {
    if (_dio != null) return; // Already initialized

    try {
      final options = BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          // For anonymous requests, only Content-Type is needed.
          'Content-Type': 'application/json',
        },
      );

      _dio = Dio(options);

      print('[PostgresLocalService] Initialized ANONYMOUS Dio client for PostgREST.');
    } catch (e) {
      print('[PostgresLocalService] Failed to initialize Dio: $e');
      rethrow;
    }
  }

  @override
  Dio get client {
    if (_dio == null) {
      throw Exception(
        '❌ PostgREST Dio client not initialized. Call initialize() first.',
      );
    }
    return _dio!;
  }

  @override
  Future<void> close() async {
    if (_dio != null) {
      _dio!.close(force: true);
      _dio = null;
      print('[PostgresLocalService] Dio client closed.');
    }
  }
}
