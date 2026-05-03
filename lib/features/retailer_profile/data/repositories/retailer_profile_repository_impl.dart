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

  Future<int> _requireUserId() async {
    final userId = await authStorage.getBuild4allUserId();

    if (userId == null) {
      throw AppException('User session not found. Please login again.');
    }

    return userId;
  }

  Future<Build4AllUserProfileModel> _getCurrentAccount() async {
    final userId = await _requireUserId();
    return retailerProfileService.getBuild4AllUserProfile(userId);
  }

  @override
  Future<RetailerProfileCombinedModel> getProfile() async {
    final account = await _getCurrentAccount();
    final business = await retailerProfileService.getRetailerBusinessProfile();

    return RetailerProfileCombinedModel(
      account: account,
      business: business,
    );
  }

  @override
  Future<AccountProfileUpdateResult> updateAccountInfo({
    required String username,
    required String firstName,
    required String lastName,
    String? changedEmail,
  }) async {
    final userId = await _requireUserId();

    return retailerProfileService.updateBuild4AllUserProfile(
      userId: userId,
      username: username,
      firstName: firstName,
      lastName: lastName,
      changedEmail: changedEmail,
    );
  }

  @override
  Future<RetailerBusinessProfileModel> updateBusinessInfo({
    required String fullName,
    required String storeName,
    required String phoneNumber,
    required String storeAddress,
    required String city,
    required String businessType,
  }) {
    return retailerProfileService.updateRetailerBusinessProfile(
      fullName: fullName,
      storeName: storeName,
      phoneNumber: phoneNumber,
      storeAddress: storeAddress,
      city: city,
      businessType: businessType,
    );
  }

  @override
  Future<void> verifyEmailChange({
    required String code,
  }) async {
    final userId = await _requireUserId();

    return retailerProfileService.verifyEmailChange(
      userId: userId,
      code: code,
    );
  }

  @override
  Future<void> resendEmailChangeCode() async {
    final userId = await _requireUserId();

    return retailerProfileService.resendEmailChangeCode(
      userId: userId,
    );
  }

  @override
  Future<void> sendPasswordResetCode({
    required String email,
  }) async {
    final account = await _getCurrentAccount();

    return retailerProfileService.sendPasswordResetCode(
      email: email,
      ownerProjectLinkId: account.ownerProjectLinkId,
    );
  }

  @override
  Future<void> updatePasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final account = await _getCurrentAccount();

    return retailerProfileService.updatePasswordWithCode(
      email: email,
      code: code,
      newPassword: newPassword,
      ownerProjectLinkId: account.ownerProjectLinkId,
    );
  }

  @override
  Future<void> deleteAccount({
    required String password,
  }) async {
    final userId = await _requireUserId();

    await retailerProfileService.deleteBuild4AllUser(
      userId: userId,
      password: password,
    );

    await retailerProfileService.deleteRetailerBusinessProfile();

    await authStorage.clearSession();
  }

  @override
  Future<void> logout() {
    return authStorage.clearSession();
  }
}