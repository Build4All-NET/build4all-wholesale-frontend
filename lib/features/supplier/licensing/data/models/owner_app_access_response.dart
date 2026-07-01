import '../../domain/entities/owner_app_access.dart';
import '../../domain/entities/plan_code.dart';
import '../../domain/entities/subscription_status.dart';

/// Data-layer JSON wrapper for [OwnerAppAccess].
class OwnerAppAccessResponse extends OwnerAppAccess {
  const OwnerAppAccessResponse({
    required super.canAccessDashboard,
    required super.blockingReason,
    required super.planCode,
    required super.planName,
    required super.subscriptionStatus,
    required super.periodEnd,
    required super.daysLeft,
    required super.usersAllowed,
    required super.activeUsers,
    required super.usersRemaining,
    required super.requiresDedicatedServer,
    required super.dedicatedInfraReady,
    required super.upgradeRequestStatus,
    required super.upgradeRequestedPlan,
    required super.upgradeRequestedAt,
    required super.upgradeDecisionNote,
    super.upcomingPlanCode,
    super.upcomingPlanName,
    super.upcomingPlanStart,
    super.upcomingPeriodEnd,
    super.upcomingPlans,
  });

  factory OwnerAppAccessResponse.fromJson(Map<String, dynamic> j) {
    final upPlanRaw = j['upgradeRequestedPlan']?.toString();
    final upcomingPlanRaw = j['upcomingPlanCode']?.toString();

    final rawUpcoming = j['upcomingPlans'];
    final upcomingPlans = <UpcomingPlan>[];
    if (rawUpcoming is List) {
      for (final e in rawUpcoming) {
        if (e is Map) {
          final codeRaw = e['planCode']?.toString();
          upcomingPlans.add(UpcomingPlan(
            planCode: (codeRaw == null || codeRaw.isEmpty)
                ? null
                : planCodeFromString(codeRaw),
            planName: e['planName']?.toString(),
            periodStart: e['periodStart']?.toString(),
            periodEnd: e['periodEnd']?.toString(),
          ));
        }
      }
    }

    int toInt(dynamic v) =>
        v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

    return OwnerAppAccessResponse(
      canAccessDashboard: j['canAccessDashboard'] == true,
      blockingReason: j['blockingReason'] as String?,
      planCode: j['planCode'] != null
          ? planCodeFromString(j['planCode'].toString())
          : null,
      planName: j['planName'] as String?,
      subscriptionStatus: j['subscriptionStatus'] != null
          ? subscriptionStatusFromString(j['subscriptionStatus'].toString())
          : null,
      periodEnd: j['periodEnd']?.toString(),
      daysLeft: toInt(j['daysLeft']),
      usersAllowed: j['usersAllowed'] == null ? null : toInt(j['usersAllowed']),
      activeUsers: toInt(j['activeUsers']),
      usersRemaining:
          j['usersRemaining'] == null ? null : (j['usersRemaining'] as num).toInt(),
      requiresDedicatedServer: j['requiresDedicatedServer'] == true,
      dedicatedInfraReady: j['dedicatedInfraReady'] == true,
      upgradeRequestStatus: j['upgradeRequestStatus']?.toString(),
      upgradeRequestedPlan: (upPlanRaw == null || upPlanRaw.isEmpty)
          ? null
          : planCodeFromString(upPlanRaw),
      upgradeRequestedAt: j['upgradeRequestedAt']?.toString(),
      upgradeDecisionNote: j['upgradeDecisionNote']?.toString(),
      upcomingPlanCode: (upcomingPlanRaw == null || upcomingPlanRaw.isEmpty)
          ? null
          : planCodeFromString(upcomingPlanRaw),
      upcomingPlanName: j['upcomingPlanName']?.toString(),
      upcomingPlanStart: j['upcomingPlanStart']?.toString(),
      upcomingPeriodEnd: j['upcomingPeriodEnd']?.toString(),
      upcomingPlans: upcomingPlans,
    );
  }
}
