import '../../domain/entities/upgrade_plan.dart';
import 'plan_pricing_model.dart';

class UpgradePlanModel {
  final String code;
  final String? title;
  final String? description;
  final bool available;
  final String? unavailableReason;
  final PlanPricingModel pricing;

  const UpgradePlanModel({
    required this.code,
    required this.title,
    required this.description,
    required this.available,
    required this.unavailableReason,
    required this.pricing,
  });

  factory UpgradePlanModel.fromJson(Map<String, dynamic> j) {
    final pricingRaw = j['pricing'];
    final pricingMap = pricingRaw is Map
        ? Map<String, dynamic>.from(pricingRaw)
        : <String, dynamic>{
            'monthlyPrice': j['monthlyPrice'],
            'yearlyPrice': j['yearlyPrice'],
            'yearlyDiscountedPrice': j['yearlyDiscountedPrice'],
            'currency': j['currency'],
            'discountPercent': j['discountPercent'],
            'discountLabel': j['discountLabel'],
          };

    return UpgradePlanModel(
      code: (j['code'] ?? j['planCode'] ?? '').toString(),
      title: (j['title'] ?? j['name'] ?? j['planName'])?.toString(),
      description: j['description']?.toString(),
      available: j['available'] != false,
      unavailableReason: j['unavailableReason']?.toString(),
      pricing: PlanPricingModel.fromJson(pricingMap),
    );
  }

  UpgradePlan toEntity() {
    return UpgradePlan(
      code: code,
      title: (title != null && title!.trim().isNotEmpty) ? title : null,
      description: (description != null && description!.trim().isNotEmpty)
          ? description
          : null,
      pricing: pricing.toEntity(),
      available: available,
      unavailableReason: unavailableReason,
    );
  }
}
