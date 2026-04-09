class AuthUserEntity {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final String? provider;
  final bool profileCompleted;
  final String? token;
  final String message;

  const AuthUserEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.provider,
    required this.profileCompleted,
    required this.token,
    required this.message,
  });

  bool get isSupplier => role.toUpperCase() == 'SUPPLIER';
  bool get isRetailer => role.toUpperCase() == 'RETAILER';
}

