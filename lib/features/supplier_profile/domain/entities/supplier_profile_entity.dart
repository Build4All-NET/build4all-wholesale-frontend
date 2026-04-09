class SupplierProfileEntity {
  final int? id;
  final int userId;
  final String companyName;
  final String companyAddress;
  final String phoneNumber;
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
    required this.city,
    required this.businessType,
    required this.description,
    required this.logoUrl,
  });
}
