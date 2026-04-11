import '../entities/supplier_profile_entity.dart';

abstract class SupplierProfileRepository {
  Future<SupplierProfileEntity> createSupplierProfile({
    required int userId,
    required String companyName,
    required String companyAddress,
    required String phoneNumber,
    required String city,
    required String businessType,
    required String description,
    required String logoUrl,
  });
}

