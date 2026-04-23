class User {
  final int id;
  final String email;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role};
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final User user;

  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}
