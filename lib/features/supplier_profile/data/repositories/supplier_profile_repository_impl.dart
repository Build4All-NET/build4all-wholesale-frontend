import '../../domain/entities/supplier_profile_entity.dart';
import '../../domain/repositories/supplier_profile_repository.dart';
import '../models/supplier_profile_request_model.dart';
import '../services/supplier_profile_service.dart';

class SupplierProfileRepositoryImpl implements SupplierProfileRepository {
  final SupplierProfileService supplierProfileService;

  SupplierProfileRepositoryImpl({required this.supplierProfileService});

  @override
  Future<SupplierProfileEntity> createSupplierProfile({
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
  }) async {
    final uploadedLogoUrl = await supplierProfileService.uploadSupplierLogo(
      logoImagePath,
    );

    final response = await supplierProfileService.createSupplierProfile(
      request: SupplierProfileRequestModel(
        companyName: companyName,
        companyAddress: companyAddress,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        regionId: regionId,
        city: city,
        businessType: businessType,
        description: description,
        logoUrl: uploadedLogoUrl,
      ),
    );

    return response;
  }
}
