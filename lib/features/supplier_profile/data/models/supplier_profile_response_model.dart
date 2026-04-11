import '../../domain/entities/supplier_profile_entity.dart';

class SupplierProfileResponseModel extends SupplierProfileEntity {
  const SupplierProfileResponseModel({
    required super.id,
    required super.userId,
    required super.companyName,
    required super.companyAddress,
    required super.phoneNumber,
    required super.city,
    required super.businessType,
    required super.description,
    required super.logoUrl,
  });

  factory SupplierProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return SupplierProfileResponseModel(
      id: json['id'],
      userId: json['userId'] ?? 0,
      companyName: json['companyName'] ?? '',
      companyAddress: json['companyAddress'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      city: json['city'] ?? '',
      businessType: json['businessType'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }
}

