import '../../domain/entities/auth_user_entity.dart';

class AuthResponseModel extends AuthUserEntity {
  const AuthResponseModel({
    required super.userId,
    required super.fullName,
    required super.email,
    required super.role,
    required super.provider,
    required super.profileCompleted,
    required super.token,
    required super.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      provider: json['provider'],
      profileCompleted: json['profileCompleted'] ?? false,
      token: json['token'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'role': role,
      'provider': provider,
      'profileCompleted': profileCompleted,
      'token': token,
      'message': message,
    };
  }
}

