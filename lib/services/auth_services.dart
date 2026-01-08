import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  User? get currentUser => supabase.auth.currentUser;

  // ============= LOGIN =============
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login for: $email');
      
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        print('❌ Login failed: No user returned');
        return null;
      }

      print('✅ Auth successful, fetching user data...');

      // ✅ Fetch role dari tabel users
      final data = await supabase
          .from('users')
          .select('role, full_name')
          .eq('id', user.id)
          .maybeSingle(); // ✅ Use maybeSingle untuk handle case tidak ada data

      if (data == null) {
        print('❌ User data not found in users table');
        throw Exception('User data not found. Please contact admin.');
      }

      print('✅ Login successful: ${data['role']}');

      return {
        'uid': user.id,
        'email': user.email,
        'role': data['role'],
        'full_name': data['full_name'],
      };
      
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      throw Exception('Login failed: ${e.message}');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // ============= LOGOUT =============
  Future<void> signOut() async {
    try {
      print('🚪 Signing out...');
      await supabase.auth.signOut();
      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Signout error: $e');
      throw Exception('Logout failed: $e');
    }
  }

  // ============= GET CURRENT USER DATA =============
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final data = await supabase
          .from('users')
          .select('role, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return null;

      return {
        'uid': user.id,
        'email': user.email,
        'role': data['role'],
        'full_name': data['full_name'],
      };
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  // ============= CHECK IF USER IS ADMIN =============
  Future<bool> isAdmin() async {
    try {
      final userData = await getCurrentUserData();
      return userData?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }
}
