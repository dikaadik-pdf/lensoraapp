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
      id: json['id'],
      idProduk: json['id_produk'],
      perubahan: json['perubahan'],
      keterangan: json['keterangan'],
      tanggal: DateTime.parse(json['tanggal']),
      idUser: json['id_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_produk': idProduk,
      'perubahan': perubahan,
      'keterangan': keterangan,
      'tanggal': tanggal.toIso8601String(),
      'id_user': idUser,
    };
  }
}