import '../../domain/entities/available_payment_method.dart';
import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/owner_app_access.dart';
import '../../domain/entities/upgrade_payment_confirmation.dart';
import '../../domain/entities/upgrade_payment_intent.dart';
import '../../domain/entities/upgrade_plan.dart';
import '../../domain/entities/upgrade_request.dart';
import '../../domain/repositories/i_licensing_repository.dart';
import '../services/licensing_api_service.dart';

/// In wholesale the authenticated supplier is the app owner, so every call uses
/// the JWT-scoped `.../apps/me/*` routes (no SUPER_ADMIN act-as path).
class LicensingRepositoryImpl implements ILicensingRepository {
  final LicensingApiService api;

  LicensingRepositoryImpl(this.api);

  @override
  Future<OwnerAppAccess> getCurrentLicensePlan() => api.getCurrentLicensePlan();

  @override
  Future<OwnerAppAccess> refreshOwnerSubscription() =>
      api.getCurrentLicensePlan();

  @override
  Future<List<UpgradePlan>> getAvailableUpgradePlans() async {
    final models = await api.getAvailableUpgradePlans();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<AvailablePaymentMethod>> getAvailablePaymentMethods() async {
    final models = await api.getAvailablePaymentMethods();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<UpgradePaymentIntent> initiateUpgradePayment({
    required String planCode,
    required BillingCycle billingCycle,
    required String paymentMethodCode,
    int? usersAllowedOverride,
  }) async {
    final model = await api.initiateUpgradePayment(
      planCode: planCode,
      billingCycle: billingCycleToString(billingCycle),
      paymentMethodCode: paymentMethodCode,
      usersAllowedOverride: usersAllowedOverride,
    );
    return model.toEntity();
  }

  @override
  Future<UpgradePaymentConfirmation> confirmUpgradePayment({
    required String paymentIntentId,
  }) async {
    final model =
        await api.confirmUpgradePayment(paymentIntentId: paymentIntentId);
    return model.toEntity();
  }

  @override
  Future<List<UpgradeRequest>> listUpgradeRequests() async {
    final models = await api.listUpgradeRequests();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> requestUpgrade({
    required String planCode,
    required BillingCycle billingCycle,
    int? usersAllowedOverride,
  }) {
    return api.requestUpgradeMe(
      planCode: planCode,
      usersAllowedOverride: usersAllowedOverride,
      billingCycle: billingCycleToString(billingCycle),
    );
  }
}
