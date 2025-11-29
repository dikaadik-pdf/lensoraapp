class ProdukModel {
  final int produkID; // pastikan ini huruf besar 'ID'
  final String namaProduk;
  final String kategori;
  final double harga;
  final int stok;
  final String? fotoUrl; // pastikan ini camelCase sama persis

  ProdukModel({
    required this.produkID,
    required this.namaProduk,
    required this.kategori,
    required this.harga,
    required this.stok,
    this.fotoUrl,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      produkID: json['produkid'], // huruf kecil sesuai DB
      namaProduk: json['namaproduk'],
      kategori: json['kategori'],
      harga: (json['harga'] as num).toDouble(),
      stok: json['stok'],
      fotoUrl: json['fotourl'], // DB: fotourl
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produkid': produkID,
      'namaproduk': namaProduk,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'fotourl': fotoUrl,
    };
  }
}
 