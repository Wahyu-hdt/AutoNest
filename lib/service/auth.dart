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
            'profil_id': user.id,
            'nama': name,
            'email': user.email,
          });
        } catch (profileError) {
          debugPrint(
            'Error inserting profile for user ${user.id}: $profileError',
          );
        }

        if (response.session == null) {
          return "Sign up successful! Please check login";
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

  // Fungsi Login (
  Future<String?> Login(String email, String password) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Jika Login berhasil dan ada pengguna (sukses)
      if (response.user != null) {
        return null;
      }

      // Jika Login gagal dan ada error
      return "Invalid email or password.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred during login: ${e.toString()}.";
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
