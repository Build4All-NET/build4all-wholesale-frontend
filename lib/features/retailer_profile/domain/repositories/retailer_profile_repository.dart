import '../../data/models/retailer_profile_model.dart';

abstract class RetailerProfileRepository {
  Future<RetailerProfileCombinedModel> getProfile();

  Future<AccountProfileUpdateResult> updateAccountInfo({
    required String username,
    required String firstName,
    required String lastName,
    String? changedEmail,
  });

  Future<RetailerBusinessProfileModel> updateBusinessInfo({
    required String fullName,
    required String storeName,
    required String phoneNumber,
    required String storeAddress,
    required String city,
    required String businessType,
  });

  Future<void> verifyEmailChange({required String code});

  Future<void> resendEmailChangeCode();

  Future<void> sendPasswordResetCode({required String email});

  Future<void> updatePasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> deleteAccount({required String password});

  Future<void> logout();
}
