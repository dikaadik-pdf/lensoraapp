import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  User? get currentUser => supabase.auth.currentUser;

  /// ============= SIGN UP =============
  Future<String> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Sign up ke auth
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // Insert ke tabel users
        await insertUserToTable(
          userID: response.user!.id,
          email: email.trim(),
          role: role.toLowerCase(), // admin / petugas
        );
        return 'Sign up berhasil';
      }

      return 'Gagal sign up';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// ============= INSERT USER KE TABEL USERS =============
  Future<void> insertUserToTable({
    required String userID,
    required String email,
    required String role,
  }) async {
    await supabase.from('users').insert({
      'id': userID,
      'email': email,
      'role': role,
    });
  }

  // ============= LOGIN =============
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Login murni ke Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) return null; // email/password salah

      final uid = response.user!.id;

      // 2️⃣ Ambil role dari tabel users (opsional)
      final roleData = await supabase
          .from('users')
          .select('role')
          .eq('id', uid)
          .maybeSingle();
      print(
        'Login successful: $email with role ${roleData != null ? roleData['role'] : 'N/A'}',
      );
      return {
        'uid': uid,
        'email': response.user!.email,
        'role': roleData != null ? roleData['role'] : null, // kalau ada role
      };
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// ============= LOGOUT =============
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
