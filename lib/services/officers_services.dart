// lib/services/officers_services.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/petugas_models.dart';
import 'package:cashierapp_simulationukk2026/services/auth_services.dart';

class OfficerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  static const String _tableName = 'users'; // ✅ Sudah benar

  // ============= ADD NEW OFFICER WITH AUTH =============
  Future<Officer> addOfficerWithAuth({
    required String fullName,
    required String email,
    required String password,
    required String category,
  }) async {
    try {
      // 1️⃣ Sign up pakai AuthService
      final result = await _authService.signUp(
        email: email,
        password: password,
        role: category.toLowerCase(),
      );

      if (result != 'Sign up berhasil') {
        throw Exception(result);
      }

      // 2️⃣ Get user ID
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('Failed to get user ID after sign up');
      }

      // 3️⃣ Ambil data user yang baru dibuat
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', userId)
          .single();

      // 4️⃣ Sign out setelah create
      await _authService.signOut();

      return Officer.fromJson(response);
    } catch (e) {
      try {
        await _authService.signOut();
      } catch (_) {}
      
      throw Exception('Failed to add officer: $e');
    }
  }

  // ============= GET ALL OFFICERS =============
  Future<List<Officer>> getAllOfficers({bool ascending = false}) async {
    try {
      final response = await _supabase
          .from(_tableName) // ✅ Sudah 'users'
          .select();

      return (response as List)
          .map((json) => Officer.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load officers: $e');
    }
  }

  // ============= DELETE OFFICER =============
  Future<void> deleteOfficer(String id) async {
    try {
      // Hapus dari tabel users
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete officer: $e');
    }
  }

  // ============= GET OFFICER BY ID =============
  Future<Officer?> getOfficerById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Officer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get officer: $e');
    }
  }

  // ============= UPDATE OFFICER =============
  Future<Officer> updateOfficer({
    required String id,
    String? email,
    String? role,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (email != null) updates['email'] = email;
      if (role != null) updates['role'] = role;

      final response = await _supabase
          .from(_tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Officer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update officer: $e');
    }
  }
}