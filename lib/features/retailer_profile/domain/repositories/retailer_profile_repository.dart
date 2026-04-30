import '../../data/models/retailer_profile_model.dart';

abstract class RetailerProfileRepository {
  Future<RetailerProfileCombinedModel> getProfile();

  Future<RetailerProfileCombinedModel> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String storeName,
    required String phoneNumber,
    required String storeAddress,
    required String city,
    required String businessType,
  });

  Future<void> logout();
}
