class ResetPasswordRequestModel {
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'resetToken': resetToken,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
