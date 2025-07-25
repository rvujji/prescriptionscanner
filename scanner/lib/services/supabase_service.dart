import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: 'https://twnibexumjlbuxrmsftv.supabase.co',
        anonKey: 'sb_publishable_LObZcMtrXUImhTlSKF4-rQ_RAaxWYum',
      );
      _initialized = true;
      print('[SupabaseService] Supabase initialized successfully');
    } catch (e) {
      print('[SupabaseService] Initialization failed: $e');
      rethrow;
    }
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }
}
