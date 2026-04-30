class Build4AllUserProfileModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;

  const Build4AllUserProfileModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
  });

  String get fullName => ('$firstName $lastName').trim();

  factory Build4AllUserProfileModel.fromJson(Map<String, dynamic> json) {
    return Build4AllUserProfileModel(
      id: _toInt(json['id'] ?? json['userId']),
      username: json['username']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      profileImageUrl:
          json['profileImageUrl']?.toString() ??
          json['profilePictureUrl']?.toString(),
    );
  }
}

class RetailerBusinessProfileModel {
  final int userId;
  final String storeName;
  final String phoneNumber;
  final String storeAddress;
  final String city;
  final String businessType;

  const RetailerBusinessProfileModel({
    required this.userId,
    required this.storeName,
    required this.phoneNumber,
    required this.storeAddress,
    required this.city,
    required this.businessType,
  });

  factory RetailerBusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return RetailerBusinessProfileModel(
      userId: _toInt(json['userId']),
      storeName: json['storeName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      storeAddress: json['storeAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      businessType: json['businessType']?.toString() ?? '',
    );
  }
}

class RetailerProfileCombinedModel {
  final Build4AllUserProfileModel account;
  final RetailerBusinessProfileModel business;

  const RetailerProfileCombinedModel({
    required this.account,
    required this.business,
  });
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
