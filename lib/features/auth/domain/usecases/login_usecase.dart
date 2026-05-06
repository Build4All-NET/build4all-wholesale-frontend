import '../entities/auth_user_entity.dart';
import '../entities/login_account_type.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthUserEntity> call({
    required String email,
    required String password,
    LoginAccountType? preferredAccountType,
  }) {
    return repository.login(
      email: email,
      password: password,
      preferredAccountType: preferredAccountType,
    );
  }
}
