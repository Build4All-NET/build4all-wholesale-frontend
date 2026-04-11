class ForgotPasswordResponseEntity {
  final bool success;
  final String message;
  final String? resetToken;

  const ForgotPasswordResponseEntity({
    required this.success,
    required this.message,
    required this.resetToken,
  });
}
