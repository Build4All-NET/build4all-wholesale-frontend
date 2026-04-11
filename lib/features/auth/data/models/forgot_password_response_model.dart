import '../../domain/entities/forgot_password_response_entity.dart';

class ForgotPasswordResponseModel extends ForgotPasswordResponseEntity {
  const ForgotPasswordResponseModel({
    required super.success,
    required super.message,
    required super.resetToken,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      resetToken: json['resetToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'resetToken': resetToken,
    };
  }
}
