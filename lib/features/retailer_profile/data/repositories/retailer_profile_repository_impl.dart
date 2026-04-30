import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/repositories/retailer_profile_repository.dart';
import '../models/retailer_profile_model.dart';
import '../services/retailer_profile_service.dart';

class RetailerProfileRepositoryImpl implements RetailerProfileRepository {
  final RetailerProfileService retailerProfileService;
  final AuthStorage authStorage;

  RetailerProfileRepositoryImpl({
    required this.retailerProfileService,
    required this.authStorage,
  });

  @override
  Future<RetailerProfileCombinedModel> getProfile() async {
    final userId = await authStorage.getBuild4allUserId();

    if (userId == null) {
      throw AppException('User session not found. Please login again.');
    }

    final account = await retailerProfileService.getBuild4AllUserProfile(
      userId,
    );
    final business = await retailerProfileService.getRetailerBusinessProfile();

    return RetailerProfileCombinedModel(account: account, business: business);
  }

  @override
  Future<RetailerProfileCombinedModel> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String storeName,
    required String phoneNumber,
    required String storeAddress,
    required String city,
    required String businessType,
  }) async {
    final userId = await authStorage.getBuild4allUserId();

    if (userId == null) {
      throw AppException('User session not found. Please login again.');
    }

    final account = await retailerProfileService.updateBuild4AllUserProfile(
      userId: userId,
      username: username,
      firstName: firstName,
      lastName: lastName,
    );

    final business = await retailerProfileService.updateRetailerBusinessProfile(
      fullName: account.fullName,
      storeName: storeName,
      phoneNumber: phoneNumber,
      storeAddress: storeAddress,
      city: city,
      businessType: businessType,
    );

    return RetailerProfileCombinedModel(account: account, business: business);
  }

  @override
  Future<void> logout() {
    return authStorage.clearSession();
  }
}
