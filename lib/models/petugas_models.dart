class Officer {
  final String? id;
  final String email;
  final String? fullName;
  final String role;
  final DateTime? createdAt;

  Officer({
    this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.createdAt,
  });

  // ✅ Getter untuk display role
  String get displayRole {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'officers':
        return 'Officers';
      default:
        return role;
    }
  }

  // ✅ Getter untuk role color
  int get roleColor {
    switch (role.toLowerCase()) {
      case 'admin':
        return 0xFFFF6B6B; // Red
      case 'officers':
        return 0xFF4ECDC4; // Teal
      default:
        return 0xFF95E1D3; // Light green
    }
  }

  // ✅ FromJson dengan null safety
  factory Officer.fromJson(Map<String, dynamic> json) {
    return Officer(
      id: json['id'] as String?,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      role: json['role'] as String? ?? 'officers',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  // ✅ ToJson untuk insert/update
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.toLowerCase(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // ✅ CopyWith untuk update
  Officer copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    DateTime? createdAt,
  }) {
    return Officer(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}