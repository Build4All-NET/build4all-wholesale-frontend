import '../../../../core/config/app_config.dart';

class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'ownerProjectLinkId': AppConfig.ownerProjectLinkId,
      'appType': AppConfig.appType,
    };
  }
}
