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
      'namaproduk': namaProduk,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'fotourl': fotoUrl,
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
