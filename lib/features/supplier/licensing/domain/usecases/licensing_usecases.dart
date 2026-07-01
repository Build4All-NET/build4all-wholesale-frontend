import '../entities/available_payment_method.dart';
import '../entities/billing_cycle.dart';
import '../entities/owner_app_access.dart';
import '../entities/upgrade_payment_confirmation.dart';
import '../entities/upgrade_payment_intent.dart';
import '../entities/upgrade_plan.dart';
import '../entities/upgrade_request.dart';
import '../repositories/i_licensing_repository.dart';

class GetCurrentLicensePlan {
  final ILicensingRepository repo;
  GetCurrentLicensePlan(this.repo);
  Future<OwnerAppAccess> call() => repo.getCurrentLicensePlan();
}

class RefreshOwnerSubscription {
  final ILicensingRepository repo;
  RefreshOwnerSubscription(this.repo);
  Future<OwnerAppAccess> call() => repo.refreshOwnerSubscription();
}

class GetAvailableUpgradePlans {
  final ILicensingRepository repo;
  GetAvailableUpgradePlans(this.repo);
  Future<List<UpgradePlan>> call() => repo.getAvailableUpgradePlans();
}

class GetAvailablePaymentMethods {
  final ILicensingRepository repo;
  GetAvailablePaymentMethods(this.repo);
  Future<List<AvailablePaymentMethod>> call() =>
      repo.getAvailablePaymentMethods();
}

class InitiateUpgradePaymentParams {
  final String planCode;
  final BillingCycle billingCycle;
  final String paymentMethodCode;
  final int? usersAllowedOverride;
  const InitiateUpgradePaymentParams({
    required this.planCode,
    required this.billingCycle,
    required this.paymentMethodCode,
    this.usersAllowedOverride,
  });
}

class InitiateUpgradePayment {
  final ILicensingRepository repo;
  InitiateUpgradePayment(this.repo);
  Future<UpgradePaymentIntent> call(InitiateUpgradePaymentParams p) {
    return repo.initiateUpgradePayment(
      planCode: p.planCode,
      billingCycle: p.billingCycle,
      paymentMethodCode: p.paymentMethodCode,
      usersAllowedOverride: p.usersAllowedOverride,
    );
  }
}

class ConfirmUpgradePayment {
  final ILicensingRepository repo;
  ConfirmUpgradePayment(this.repo);
  Future<UpgradePaymentConfirmation> call({required String paymentIntentId}) {
    return repo.confirmUpgradePayment(paymentIntentId: paymentIntentId);
  }
}

class ListUpgradeRequests {
  final ILicensingRepository repo;
  ListUpgradeRequests(this.repo);
  Future<List<UpgradeRequest>> call() => repo.listUpgradeRequests();
}
