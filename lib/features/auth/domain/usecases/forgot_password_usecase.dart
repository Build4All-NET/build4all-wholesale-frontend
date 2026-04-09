import '../entities/forgot_password_response_entity.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<ForgotPasswordResponseEntity> call({
    required String email,
  }) {
    return repository.forgotPassword(email: email);
  }
}
