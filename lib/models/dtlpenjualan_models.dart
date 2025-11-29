class DetailPenjualanModel {
  final int detailID;
  final int penjualanID;
  final int produkID;
  final int jumlahProduk;
  final double hargaSatuan;
  final double subtotal;

  DetailPenjualanModel({
    required this.detailID,
    required this.penjualanID,
    required this.produkID,
    required this.jumlahProduk,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory DetailPenjualanModel.fromJson(Map<String, dynamic> json) {
    return DetailPenjualanModel(
      detailID: json['DetailID'],
      penjualanID: json['PenjualanID'],
      produkID: json['ProdukID'],
      jumlahProduk: json['JumlahProduk'],
      hargaSatuan: (json['HargaSatuan'] as num).toDouble(),
      subtotal: (json['Subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DetailID': detailID,
      'PenjualanID': penjualanID,
      'ProdukID': produkID,
      'JumlahProduk': jumlahProduk,
      'HargaSatuan': hargaSatuan,
      'Subtotal': subtotal,
    };
  }
}
