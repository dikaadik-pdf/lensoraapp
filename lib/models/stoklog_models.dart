class StokLogModel {
  final int id;
  final int idProduk;
  final int perubahan;
  final String? keterangan;
  final DateTime tanggal;
  final String? idUser;

  StokLogModel({
    required this.id,
    required this.idProduk,
    required this.perubahan,
    this.keterangan,
    required this.tanggal,
    this.idUser,
  });

  factory StokLogModel.fromJson(Map<String, dynamic> json) {
    return StokLogModel(
      id: json['ID'],
      idProduk: json['ID_Produk'],
      perubahan: json['Perubahan'],
      keterangan: json['Keterangan'],
      tanggal: DateTime.parse(json['Tanggal']),
      idUser: json['ID_User'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_Produk': idProduk,
      'Perubahan': perubahan,
      'Keterangan': keterangan,
      'Tanggal': tanggal.toIso8601String(),
      'ID_User': idUser,
    };
  }
}
