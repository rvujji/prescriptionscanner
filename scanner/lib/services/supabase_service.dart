import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';

class SupabaseService implements DatabaseService<SupabaseClient> {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: 'https://twnibexumjlbuxrmsftv.supabase.co',
        anonKey: 'sb_publishable_LObZcMtrXUImhTlSKF4-rQ_RAaxWYum',
        authOptions: FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // Required for mobile
        ),
      );
      _initialized = true;
      print('[SupabaseService] Supabase initialized successfully');
    } catch (e) {
      print('[SupabaseService] Initialization failed: $e');
      rethrow;
    }
  }

  @override
  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }

  @override
  Future<void> close() async {
    if (_initialized) {
      await client.dispose();
      _initialized = false;
      print('[SupabaseService] Supabase client disposed.');
    }
  }
}
