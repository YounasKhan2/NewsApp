import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.SUPABASE_URL,
        anonKey: SupabaseConfig.SUPABASE_ANON_KEY,
      );
      print('Supabase initialized successfully');
      print('Connected to: ${SupabaseConfig.SUPABASE_URL}');
    } catch (e) {
      print('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      print('Error accessing Supabase client: $e');
      rethrow;
    }
  }

  static User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (e) {
      print('Error accessing current user: $e');
      return null;
    }
  }

  static Stream<AuthState> get authStateChanges {
    try {
      return client.auth.onAuthStateChange;
    } catch (e) {
      print('Error accessing auth state changes: $e');
      rethrow;
    }
  }
}