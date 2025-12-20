class UserModel {
  final String email;
  final String fullName;
  final DateTime? createdAt;

  UserModel({required this.email, required this.fullName, this.createdAt});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
