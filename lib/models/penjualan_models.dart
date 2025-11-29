import 'dtlpenjualan_models.dart';

class PenjualanModel {
  final int penjualanID;
  final int? pelangganID;
  final DateTime tanggalPenjualan;
  final double totalHarga;
  final String metodePembayaran;
  final double diskon;
  final double grandTotal;
  final String noTransaksi;
  final String? userID;
  final List<DetailPenjualanModel> details;

  PenjualanModel({
    required this.penjualanID,
    required this.pelangganID,
    required this.tanggalPenjualan,
    required this.totalHarga,
    required this.metodePembayaran,
    required this.diskon,
    required this.grandTotal,
    required this.noTransaksi,
    required this.userID,
    this.details = const [],
  });

  factory PenjualanModel.fromJson(Map<String, dynamic> json) {
    return PenjualanModel(
      penjualanID: json['PenjualanID'],
      pelangganID: json['PelangganID'],
      tanggalPenjualan: DateTime.parse(json['TanggalPenjualan']),
      totalHarga: (json['TotalHarga'] as num).toDouble(),
      metodePembayaran: json['MetodePembayaran'],
      diskon: (json['Diskon'] as num).toDouble(),
      grandTotal: (json['GrandTotal'] as num).toDouble(),
      noTransaksi: json['NoTransaksi'],
      userID: json['UserID'],
      details: json['details'] != null
          ? (json['details'] as List)
              .map((e) => DetailPenjualanModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PenjualanID': penjualanID,
      'PelangganID': pelangganID,
      'TanggalPenjualan': tanggalPenjualan.toIso8601String(),
      'TotalHarga': totalHarga,
      'MetodePembayaran': metodePembayaran,
      'Diskon': diskon,
      'GrandTotal': grandTotal,
      'NoTransaksi': noTransaksi,
      'UserID': userID,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}
