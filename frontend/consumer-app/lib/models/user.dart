class User {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String role;
  final String status;
  final String? avatarUrl;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.status,
    this.avatarUrl,
    required this.emailVerified,
    required this.phoneVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      avatarUrl: json['avatarUrl'],
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'status': status,
      'avatarUrl': avatarUrl,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}



















