import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // ➕ Tambah produk
  Future<void> addProduct(
    String namaProduk,
    String kategori,
    double harga,
    int stok,
    String? fotoUrl,
  ) async {
    await supabase.from('produk').insert({
      'NamaProduk': namaProduk,
      'Kategori': kategori,
      'Harga': harga,
      'Stok': stok,
      'Foto_url': fotoUrl,
    });
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await supabase.from('produk').select();
    return (response as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await supabase
        .from('produk')
        .update(data)
        .eq('ProdukID', id);
  }

  Future<void> deleteProduct(int id) async {
    await supabase
        .from('produk')
        .delete()
        .eq('ProdukID', id);
  }
}
