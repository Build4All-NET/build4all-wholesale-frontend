class RetailerSignupRequestModel {
  final String fullName;
  final String storeName;
  final String phoneNumber;
  final String email;
  final String password;
  final String confirmPassword;
  final String storeAddress;
  final String city;
  final String businessType;

  const RetailerSignupRequestModel({
    required this.fullName,
    required this.storeName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.storeAddress,
    required this.city,
    required this.businessType,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'storeName': storeName,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'storeAddress': storeAddress,
      'city': city,
      'businessType': businessType,
    };
  }
}
