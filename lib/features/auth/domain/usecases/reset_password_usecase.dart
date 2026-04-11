import '../entities/api_response_entity.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<ApiResponseEntity> call({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return repository.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
