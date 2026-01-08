import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/petugas_models.dart';

class OfficerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'users';

  // ================= ADD NEW OFFICER WITH AUTH =================
  Future<Officer> addOfficerWithAuth({
    required String fullName,
    required String email,
    required String password,
    required String category,
  }) async {
    try {
      print('🚀 Starting signup for: $email');

      // 1️⃣ Signup user baru
      final authResponse = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName,
          'role': category.toLowerCase(),
        },
      );

      final newUser = authResponse.user;
      if (newUser == null) {
        throw Exception('Failed to create user account');
      }

      print('✅ Auth user created: ${newUser.id}');

      // 2️⃣ Wait untuk trigger selesai (lebih agresif)
      Officer? officer;
      int attempts = 0;
      const maxAttempts = 10;
      
      while (attempts < maxAttempts && officer == null) {
        // Progressive delay: 200ms, 400ms, 600ms, 800ms, dst
        await Future.delayed(Duration(milliseconds: 200 + (attempts * 200)));
        
        print('🔄 Attempt ${attempts + 1}/$maxAttempts: Checking database...');
        
        try {
          final data = await _supabase
              .from(_tableName)
              .select()
              .eq('id', newUser.id)
              .maybeSingle();
          
          if (data != null) {
            officer = Officer.fromJson(data);
            print('✅ Officer data found!');
            break;
          }
        } catch (e) {
          print('⚠️ Attempt ${attempts + 1} error: $e');
        }
        
        attempts++;
      }

      // 3️⃣ Jika trigger gagal, insert manual
      if (officer == null) {
        print('⚠️ Trigger didn\'t work, trying manual insert...');
        
        try {
          final manualData = await _supabase
              .from(_tableName)
              .insert({
                'id': newUser.id,
                'email': email.trim().toLowerCase(),
                'full_name': fullName,
                'role': category.toLowerCase(),
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

          officer = Officer.fromJson(manualData);
          print('✅ Manual insert successful!');
        } catch (insertError) {
          print('❌ Manual insert failed: $insertError');
          
          // Last attempt: fetch lagi
          await Future.delayed(const Duration(milliseconds: 500));
          final lastAttempt = await _supabase
              .from(_tableName)
              .select()
              .eq('id', newUser.id)
              .maybeSingle();
          
          if (lastAttempt != null) {
            officer = Officer.fromJson(lastAttempt);
            print('✅ Found on last attempt!');
          }
        }
      }

      // 4️⃣ Final validation
      if (officer == null) {
        throw Exception(
          'SYNC_ERROR: User created (${newUser.id}) but database sync failed. '
          'Please check RLS policies and try refreshing the page.'
        );
      }

      print('🎉 Officer created successfully: ${officer.email}');
      return officer;

    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      
      if (e.message.contains('already registered') || 
          e.message.contains('User already registered')) {
        throw Exception('Email sudah terdaftar!');
      } else if (e.message.contains('Invalid email')) {
        throw Exception('Format email tidak valid!');
      } else if (e.message.contains('Password should be at least')) {
        throw Exception('Password terlalu lemah! Minimal 6 karakter.');
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('Email confirmation enabled. Please disable it in Supabase Auth settings.');
      } else if (e.message.contains('Signups not allowed')) {
        throw Exception('User registration disabled. Enable it in Supabase Auth settings.');
      }
      
      throw Exception('Auth error: ${e.message}');
      
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      
      if (e.code == '23505') {
        throw Exception('Email sudah terdaftar!');
      } else if (e.code == '42501') {
        throw Exception('Permission denied. Check your RLS policies in Supabase.');
      } else if (e.code == 'PGRST116') {
        throw Exception('No data found. Check your RLS SELECT policy.');
      }
      
      throw Exception('Database error: ${e.message}');
      
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Failed to add officer: $e');
    }
  }

  // ================= GET ALL OFFICERS =================
  Future<List<Officer>> getAllOfficers({bool ascending = false}) async {
    try {
      print('📥 Fetching all officers...');
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: ascending);

      final officers = (response as List)
          .map((json) => Officer.fromJson(json))
          .toList();

      print('✅ Loaded ${officers.length} officers');
      return officers;
      
    } on PostgrestException catch (e) {
      print('❌ PostgrestException in getAllOfficers: ${e.code} - ${e.message}');
      
      if (e.code == '42501') {
        throw Exception('Permission denied. Check your RLS SELECT policy.');
      } else if (e.code == 'PGRST116') {
        // No rows found is OK
        return [];
      }
      
      throw Exception('Failed to load officers: ${e.message}');
    } catch (e) {
      print('❌ Error in getAllOfficers: $e');
      throw Exception('Failed to load officers: $e');
    }
  }

  // ================= DELETE OFFICER =================
  Future<void> deleteOfficer(String id) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Must be logged in to delete officer');
      }

      if (currentUser.id == id) {
        throw Exception('Cannot delete your own account!');
      }

      print('🗑️ Deleting user: $id');

      // Delete dari auth (akan cascade ke tabel users jika trigger setup benar)
      await _supabase.auth.admin.deleteUser(id);
      
      print('✅ User deleted successfully');

    } on AuthException catch (e) {
      print('❌ AuthException in delete: ${e.message}');
      
      if (e.message.contains('not found')) {
        // User sudah tidak ada, coba hapus dari tabel saja
        await _supabase.from(_tableName).delete().eq('id', id);
      } else {
        throw Exception('Auth error: ${e.message}');
      }
    } catch (e) {
      print('❌ Error in delete: $e');
      throw Exception('Failed to delete officer: $e');
    }
  }

  // ================= GET OFFICER BY ID =================
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

  // ================= UPDATE OFFICER =================
  Future<Officer> updateOfficer({
    required String id,
    String? email,
    String? role,
    String? fullName,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (email != null) updates['email'] = email.trim().toLowerCase();
      if (role != null) updates['role'] = role.toLowerCase();
      if (fullName != null) updates['full_name'] = fullName;

      if (updates.isEmpty) {
        throw Exception('No data to update');
      }

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

  // ================= GET OFFICERS BY ROLE =================
  Future<List<Officer>> getOfficersByRole(String role) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('role', role.toLowerCase())
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Officer.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load officers by role: $e');
    }
  }

  // ================= SEARCH OFFICERS =================
  Future<List<Officer>> searchOfficers(String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Officer.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search officers: $e');
    }
  }
}