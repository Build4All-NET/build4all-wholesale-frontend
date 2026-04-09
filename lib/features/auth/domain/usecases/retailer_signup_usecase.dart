import '../entities/api_response_entity.dart';
import '../repositories/auth_repository.dart';

class RetailerSignupUseCase {
  final AuthRepository repository;

  RetailerSignupUseCase(this.repository);

  Future<ApiResponseEntity> call({
    required String fullName,
    required String storeName,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
    required String storeAddress,
    required String city,
    required String businessType,
  }) {
    return repository.retailerSignup(
      fullName: fullName,
      storeName: storeName,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      storeAddress: storeAddress,
      city: city,
      businessType: businessType,
    );
  }
}
