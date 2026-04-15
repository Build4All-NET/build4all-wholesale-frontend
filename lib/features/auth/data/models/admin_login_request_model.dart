class AdminLoginRequestModel {
  final String usernameOrEmail;
  final String password;
  final int? ownerProjectId;

  const AdminLoginRequestModel({
    required this.usernameOrEmail,
    required this.password,
    this.ownerProjectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
      'ownerProjectId': ownerProjectId,
    };
  }
}
