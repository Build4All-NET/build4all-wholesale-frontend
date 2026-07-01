import '../entities/available_payment_method.dart';
import '../entities/billing_cycle.dart';
import '../entities/owner_app_access.dart';
import '../entities/upgrade_payment_confirmation.dart';
import '../entities/upgrade_payment_intent.dart';
import '../entities/upgrade_plan.dart';
import '../entities/upgrade_request.dart';

abstract class ILicensingRepository {
  Future<OwnerAppAccess> getCurrentLicensePlan();

  Future<List<UpgradePlan>> getAvailableUpgradePlans();

  Future<List<AvailablePaymentMethod>> getAvailablePaymentMethods();

  Future<UpgradePaymentIntent> initiateUpgradePayment({
    required String planCode,
    required BillingCycle billingCycle,
    required String paymentMethodCode,
    int? usersAllowedOverride,
  });

  Future<UpgradePaymentConfirmation> confirmUpgradePayment({
    required String paymentIntentId,
  });

  Future<OwnerAppAccess> refreshOwnerSubscription();

  Future<List<UpgradeRequest>> listUpgradeRequests();

  Future<void> requestUpgrade({
    required String planCode,
    required BillingCycle billingCycle,
    int? usersAllowedOverride,
  });
}
