class AdminLoginResponseModel {
  final String message;
  final String token;
  final String refreshToken;
  final String role;
  final int? ownerProjectId;
  final Map<String, dynamic>? admin;

  const AdminLoginResponseModel({
    required this.message,
    required this.token,
    required this.refreshToken,
    required this.role,
    required this.ownerProjectId,
    required this.admin,
  });

  factory AdminLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminLoginResponseModel(
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      ownerProjectId: json['ownerProjectId'] is int
          ? json['ownerProjectId'] as int
          : int.tryParse(json['ownerProjectId']?.toString() ?? ''),
      admin: json['admin'] is Map<String, dynamic>
          ? json['admin'] as Map<String, dynamic>
          : null,
    );
  }
}
