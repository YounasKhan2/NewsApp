import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';

class AuthService {
  final _supabase = SupabaseService.client;

  User? get currentUser => _supabase.auth.currentUser;

  // Email Sign Up with email verification
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      print("Attempting signup for email: $email");
      final response = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
          },
          emailRedirectTo: 'com.pulsenews.app://login-callback/'
      );

      print("Signup response received: ${response.session != null ? 'with session' : 'without session'}");
      return response;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Email Sign In with detailed logging
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print("AuthService: Attempting sign in for email: $email");
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print("AuthService: Sign in response received");
      if (response.user != null) {
        print("AuthService: User authenticated successfully");

        // Update last login
        try {
          await _supabase.from('user_profiles').update({
            'last_login': DateTime.now().toIso8601String(),
          }).eq('id', response.user!.id);
          print("AuthService: Last login timestamp updated");
        } catch (profileError) {
          print("AuthService: Profile update error (non-critical): $profileError");
          // Non-critical error, we can continue
        }
      } else {
        print("AuthService: Response contained no user");
      }

      return response;
    } catch (e) {
      print("AuthService error during sign in: $e");
      if (e.toString().contains("network")) {
        print("AuthService: Network connectivity issue detected");
      }
      rethrow;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail(String email) async {
    try {
      print("Resending verification email to: $email");
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      print("Verification email resent successfully");
    } catch (e) {
      print("Error resending verification: $e");
      rethrow;
    }
  }

  // Google Sign In (temporarily disabled)
  Future<bool> signInWithGoogle() async {
    print('Google Sign-In temporarily disabled');
    return false;
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}