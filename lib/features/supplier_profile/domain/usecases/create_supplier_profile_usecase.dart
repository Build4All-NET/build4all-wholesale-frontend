import '../entities/supplier_profile_entity.dart';
import '../repositories/supplier_profile_repository.dart';

class CreateSupplierProfileUseCase {
  final SupplierProfileRepository repository;

  CreateSupplierProfileUseCase(this.repository);

  Future<SupplierProfileEntity> call({
    required int userId,
    required String companyName,
    required String companyAddress,
    required String phoneNumber,
    required String countryCode,
    int? regionId,
    required String city,
    required String businessType,
    required String description,
    required String logoImagePath,
  }) {
    return repository.createSupplierProfile(
      userId: userId,
      companyName: companyName,
      companyAddress: companyAddress,
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      regionId: regionId,
      city: city,
      businessType: businessType,
      description: description,
      logoImagePath: logoImagePath,
    );
  }
}
