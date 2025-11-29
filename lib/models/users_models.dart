class UserModel {
  final String userID;
  final String email;
  final String password;
  final String role;

  UserModel({
    required this.userID,
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    userID: json['id'],
    email: json['email'],
    password: '', // kosong aja, jangan ambil dari tabel
    role: json['role'],
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': userID,
    'email': email,
    'role': role,
  };
}

}
