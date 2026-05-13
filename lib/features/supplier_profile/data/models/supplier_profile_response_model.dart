import '../../domain/entities/supplier_profile_entity.dart';

class SupplierProfileResponseModel extends SupplierProfileEntity {
  const SupplierProfileResponseModel({
    required super.id,
    required super.userId,
    required super.companyName,
    required super.companyAddress,
    required super.phoneNumber,
    super.countryCode = '',
    super.countryName = '',
    super.regionId,
    super.regionName = '',
    required super.city,
    required super.businessType,
    required super.description,
    required super.logoUrl,
  });

  factory SupplierProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return SupplierProfileResponseModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      companyName: json['companyName']?.toString() ?? '',
      companyAddress: json['companyAddress']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      countryCode: json['countryCode']?.toString().toUpperCase() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      regionId: int.tryParse(json['regionId']?.toString() ?? ''),
      regionName: json['regionName']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      businessType: json['businessType']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
    );
  }
}
