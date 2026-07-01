import 'plan_code.dart';
import 'subscription_status.dart';

/// One purchased-but-not-yet-started paid plan in the owner's queue.
class UpcomingPlan {
  final PlanCode? planCode;
  final String? planName;
  final String? periodStart;
  final String? periodEnd;

  const UpcomingPlan({
    this.planCode,
    this.planName,
    this.periodStart,
    this.periodEnd,
  });
}

/// Current license / access snapshot for the owner (in wholesale: the supplier
/// who owns the app). JSON parsing lives in the data layer.
class OwnerAppAccess {
  final bool canAccessDashboard;
  final String? blockingReason;

  final PlanCode? planCode;
  final String? planName;

  final SubscriptionStatus? subscriptionStatus;
  final String? periodEnd;
  final int daysLeft;

  final int? usersAllowed;
  final int activeUsers;
  final int? usersRemaining;

  final bool requiresDedicatedServer;
  final bool dedicatedInfraReady;

  final String? upgradeRequestStatus; // PENDING / APPROVED / REJECTED / null
  final PlanCode? upgradeRequestedPlan;
  final String? upgradeRequestedAt;
  final String? upgradeDecisionNote;

  final PlanCode? upcomingPlanCode;
  final String? upcomingPlanName;
  final String? upcomingPlanStart;
  final String? upcomingPeriodEnd;

  final List<UpcomingPlan> upcomingPlans;

  const OwnerAppAccess({
    required this.canAccessDashboard,
    required this.blockingReason,
    required this.planCode,
    required this.planName,
    required this.subscriptionStatus,
    required this.periodEnd,
    required this.daysLeft,
    required this.usersAllowed,
    required this.activeUsers,
    required this.usersRemaining,
    required this.requiresDedicatedServer,
    required this.dedicatedInfraReady,
    required this.upgradeRequestStatus,
    required this.upgradeRequestedPlan,
    required this.upgradeRequestedAt,
    required this.upgradeDecisionNote,
    this.upcomingPlanCode,
    this.upcomingPlanName,
    this.upcomingPlanStart,
    this.upcomingPeriodEnd,
    this.upcomingPlans = const [],
  });

  bool get hasPendingUpgradeRequest =>
      (upgradeRequestStatus ?? '').toUpperCase() == 'PENDING';

  /// Locked out with no usable license — the owner must be able to (re)start
  /// the pay/upgrade flow. Excludes soft blocks that paying doesn't resolve.
  bool get isLicenseBlocked {
    if (canAccessDashboard != false) return false;
    final r = (blockingReason ?? '').trim().toUpperCase();
    return r != 'USER_LIMIT_REACHED' && r != 'DEDICATED_SERVER_NOT_ASSIGNED';
  }

  bool get hasUpcomingPlan =>
      upcomingPlans.isNotEmpty ||
      upcomingPlanCode != null ||
      (upcomingPlanName ?? '').trim().isNotEmpty;
}
