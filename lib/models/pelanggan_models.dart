class PelangganModel {
  int? pelangganID;
  String namaPelanggan;
  String? alamat;
  String? nomorTelepon;
  String? lastTransaction;
  double? totalExpenditure;

  PelangganModel({
    this.pelangganID,
    required this.namaPelanggan,
    this.alamat,
    this.nomorTelepon,
    this.lastTransaction,
    this.totalExpenditure,
  });

  factory PelangganModel.fromJson(Map<String, dynamic> json) {
    return PelangganModel(
      pelangganID: json['pelangganid'] as int?,
      namaPelanggan: json['namapelanggan'] as String? ?? '',
      alamat: json['alamat'] as String?,
      nomorTelepon: json['nomortelepon'] as String?,
      lastTransaction: json['last_transaction'] as String?,
      totalExpenditure: json['total_expenditure'] != null
          ? double.tryParse(json['total_expenditure'].toString())
          : 0.0,
    );
  }

  // toJson diperbaiki agar insert dan update tidak kirim ID
  Map<String, dynamic> toJson({bool forInsert = false, bool forUpdate = false}) {
    final data = <String, dynamic>{
      'namapelanggan': namaPelanggan,
      'alamat': alamat ?? '',
      'nomortelepon': nomorTelepon ?? '',
    };
    
    // JANGAN PERNAH kirim pelangganID untuk insert atau update
    // ID hanya untuk select/read operations
    // Database akan auto-generate (insert) atau mempertahankan (update) ID
    
    return data;
  }

  // Helper untuk UI supaya ID bisa jadi string
  String get pelangganIDString => pelangganID?.toString() ?? '0';
  
  // Copy with method untuk memudahkan update
  PelangganModel copyWith({
    int? pelangganID,
    String? namaPelanggan,
    String? alamat,
    String? nomorTelepon,
    String? lastTransaction,
    double? totalExpenditure,
  }) {
    return PelangganModel(
      pelangganID: pelangganID ?? this.pelangganID,
      namaPelanggan: namaPelanggan ?? this.namaPelanggan,
      alamat: alamat ?? this.alamat,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      lastTransaction: lastTransaction ?? this.lastTransaction,
      totalExpenditure: totalExpenditure ?? this.totalExpenditure,
    );
  }
}