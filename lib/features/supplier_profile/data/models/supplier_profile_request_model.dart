class SupplierProfileRequestModel {
  final String companyName;
  final String companyAddress;
  final String phoneNumber;
  final String city;
  final String businessType;
  final String description;
  final String logoUrl;

  const SupplierProfileRequestModel({
    required this.companyName,
    required this.companyAddress,
    required this.phoneNumber,
    required this.city,
    required this.businessType,
    required this.description,
    required this.logoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'companyAddress': companyAddress,
      'phoneNumber': phoneNumber,
      'city': city,
      'businessType': businessType,
      'description': description,
      'logoUrl': logoUrl,
    };
  }
}
