class DetailPenjualanModel {
  final int? detailID;
  final int penjualanID;
  final int produkID;
  final int jumlahProduk;
  final double hargaSatuan;
  final double subtotal;

  DetailPenjualanModel({
    this.detailID,
    required this.penjualanID,
    required this.produkID,
    required this.jumlahProduk,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory DetailPenjualanModel.fromJson(Map<String, dynamic> json) {
    return DetailPenjualanModel(
      detailID: json['detailid'],
      penjualanID: json['penjualanid'],
      produkID: json['produkid'],
      jumlahProduk: json['jumlahproduk'],
      hargaSatuan: (json['hargasatuan'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'penjualanid': penjualanID,
      'produkid': produkID,
      'jumlahproduk': jumlahProduk,
      'hargasatuan': hargaSatuan,
      'subtotal': subtotal,
    };
  }
}