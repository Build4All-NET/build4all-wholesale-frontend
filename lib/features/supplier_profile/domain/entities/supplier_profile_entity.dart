class SupplierProfileEntity {
  final int? id;
  final int userId;
  final String companyName;
  final String companyAddress;
  final String phoneNumber;
  final String countryCode;
  final String countryName;
  final int? regionId;
  final String regionName;
  final String city;
  final String businessType;
  final String description;
  final String logoUrl;

  const SupplierProfileEntity({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.companyAddress,
    required this.phoneNumber,
    this.countryCode = '',
    this.countryName = '',
    this.regionId,
    this.regionName = '',
    required this.city,
    required this.businessType,
    required this.description,
    required this.logoUrl,
  });
}
