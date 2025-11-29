class PelangganModel {
  final int pelangganID;
  final String namaPelanggan;
  final String? alamat;
  final String? nomorTelepon;

  PelangganModel({
    required this.pelangganID,
    required this.namaPelanggan,
    this.alamat,
    this.nomorTelepon,
  });

  factory PelangganModel.fromJson(Map<String, dynamic> json) {
    return PelangganModel(
      pelangganID: json['PelangganID'],
      namaPelanggan: json['NamaPelanggan'],
      alamat: json['Alamat'],
      nomorTelepon: json['NomorTelepon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PelangganID': pelangganID,
      'NamaPelanggan': namaPelanggan,
      'Alamat': alamat,
      'NomorTelepon': nomorTelepon,
    };
  }
}
