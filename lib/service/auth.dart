import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Fungsi Sign Up
  Future<String?> signup(
    String email,
    String password, {
    required String name,
  }) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = response.user!;

        try {
          await supabase.from('Profil').insert({
            'profil_id': user.id, // Menggunakan 'profil_id' sesuai tabel Anda
            'nama': name,
            'email': user.email,
          });
          debugPrint('Profile for user ${user.id} inserted successfully.');
        } catch (profileError) {
          debugPrint(
            'Error inserting profile for user ${user.id}: $profileError',
          );
        }

        if (response.session == null) {
          return "Sign up successful! Please check your email for verification if required, then log in.";
        } else {
          return null; // Sukses, tidak ada pesan error
        }
      } else {
        return "Sign up failed: User object not returned after signup.";
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}.";
    }
  }

  // Fungsi Login

  Future<String?> login(String email, String password) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return null; // Tidak ada error
      }

      return "Invalid email or password.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred during login: ${e.toString()}.";
    }
  }

  // Fungsi Forgot Password
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}.";
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/loginsignup');
      }
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }
}
