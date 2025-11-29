class LaporanPenjualanModel {
  final String noTransaksi;
  final String? namaPelanggan;
  final String? kasir;
  final DateTime tanggal;
  final double total;
  final double diskon;
  final double grandTotal;

  LaporanPenjualanModel({
    required this.noTransaksi,
    this.namaPelanggan,
    this.kasir,
    required this.tanggal,
    required this.total,
    required this.diskon,
    required this.grandTotal,
  });

  factory LaporanPenjualanModel.fromJson(Map<String, dynamic> json) {
    return LaporanPenjualanModel(
      noTransaksi: json['no_transaksi'],
      namaPelanggan: json['nama_pelanggan'],
      kasir: json['kasir'],
      tanggal: DateTime.parse(json['tanggal']),
      total: (json['total'] as num).toDouble(),
      diskon: (json['diskon'] as num).toDouble(),
      grandTotal: (json['grand_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no_transaksi': noTransaksi,
      'nama_pelanggan': namaPelanggan,
      'kasir': kasir,
      'tanggal': tanggal.toIso8601String(),
      'total': total,
      'diskon': diskon,
      'grand_total': grandTotal,
    };
  }
}
