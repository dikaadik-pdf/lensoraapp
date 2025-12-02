import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';

class PelangganDatabaseHelper {
  static final _supabase = Supabase.instance.client;

  // Get all customers
  static Future<List<PelangganModel>> getAllPelanggan() async {
    try {
      final response = await _supabase
          .from('pelanggan')
          .select()
          .order('pelangganid');
      return (response as List)
          .map((e) => PelangganModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getting all pelanggan: $e');
      rethrow;
    }
  }

  // Add new customer
  static Future<PelangganModel?> addPelanggan(PelangganModel pelanggan) async {
    try {
      final response = await _supabase
          .from('pelanggan')
          .insert(pelanggan.toJson(forInsert: true)) // JANGAN kirim pelangganID
          .select()
          .single();
      return PelangganModel.fromJson(response);
    } catch (e) {
      print('Error adding pelanggan: $e');
      rethrow;
    }
  }

  // Update existing customer
  static Future<PelangganModel?> updatePelanggan(PelangganModel pelanggan) async {
    try {
      if (pelanggan.pelangganID == null) {
        throw Exception('pelangganID cannot be null for update');
      }

      // PENTING: toJson() TIDAK boleh include pelangganID dalam body
      // pelangganID hanya digunakan di .eq() untuk WHERE clause
      final response = await _supabase
          .from('pelanggan')
          .update(pelanggan.toJson(forUpdate: true)) // Exclude ID dari body
          .eq('pelangganid', pelanggan.pelangganID!) // ID hanya untuk WHERE
          .select()
          .single();
      return PelangganModel.fromJson(response);
    } catch (e) {
      print('Error updating pelanggan: $e');
      rethrow;
    }
  }

  // Delete customer
  static Future<void> deletePelanggan(int pelangganID) async {
    try {
      await _supabase
          .from('pelanggan')
          .delete()
          .eq('pelangganid', pelangganID);
    } catch (e) {
      print('Error deleting pelanggan: $e');
      rethrow;
    }
  }

  // Get transaction history for a customer
  static Future<List<Map<String, dynamic>>> getTransactionHistory(int pelangganID) async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('*, details:detailpenjualan(*, produk(*))')
          .eq('pelangganid', pelangganID)
          .order('tanggalpenjualan', ascending: false);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting transaction history: $e');
      rethrow;
    }
  }

  // Get customer by ID
  static Future<PelangganModel?> getPelangganById(int pelangganID) async {
    try {
      final response = await _supabase
          .from('pelanggan')
          .select()
          .eq('pelangganid', pelangganID)
          .single();
      return PelangganModel.fromJson(response);
    } catch (e) {
      print('Error getting pelanggan by ID: $e');
      return null;
    }
  }
}