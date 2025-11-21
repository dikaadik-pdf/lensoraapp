import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class AuthService {
  final SupabaseClient _client = SupabaseClientService.client;
  final String _table = 'users';

  Future<String?> signUp({
    required String email,
    required String password,
    String role = 'petugas',
  }) async {
    try {
      final existingUser = await _client
          .from(_table)
          .select()
          .eq('Email', email)
          .maybeSingle();

      if (existingUser != null) return 'Email sudah terdaftar';

      await _client.from(_table).insert({
        'Email': email,
        'Password': password,
        'Role': role,
      });

      return 'Sign up berhasil';
    } catch (e) {
      return 'Gagal sign up: $e';
    }
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client
          .from(_table)
          .select()
          .eq('Email', email)
          .eq('Password', password)
          .maybeSingle();

      if (res == null) return null;
      return Map<String, dynamic>.from(res);
    } catch (e) {
      print('Error login: $e');
      return null;
    }
  }
}
