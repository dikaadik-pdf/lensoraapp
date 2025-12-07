class Officer {
  final String? id;
  final String email;
  final String role;
  final num? data;

  Officer({this.id, required this.email, required this.role, this.data});

  factory Officer.fromJson(Map<String, dynamic> json) {
    return Officer(
      id: json['id']?.toString(),
      email: json['email'] ?? '',
      role: json['role'] ?? 'petugas',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'role': role,
      if (data != null) 'data': data,
    };
  }

  Officer copyWith({String? id, String? email, String? role, num? data}) {
    return Officer(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      data: data ?? this.data,
    );
  }

  bool get isAdmin => role.toLowerCase() == 'admin';

  int get roleColor {
    return isAdmin ? 0xFFBF0505 : 0xFFE4B169;
  }

  String get displayRole {
    if (role.isEmpty) return 'Petugas';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  String get fullName {
    return email.split('@')[0];
  }

  @override
  String toString() {
    return 'Officer(id: $id, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Officer &&
        other.id == id &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ role.hashCode;
  }
}
