import '../entities/tax_preview_entity.dart';
import '../entities/tax_rule_entity.dart';

abstract class TaxRuleRepository {
  Future<List<TaxRuleEntity>> getTaxRules();

  Future<TaxRuleEntity> createTaxRule(TaxRuleEntity rule);

  Future<TaxRuleEntity> updateTaxRule(TaxRuleEntity rule);

  Future<void> deleteTaxRule(String id);

  Future<TaxPreviewEntity> previewTax({
    required String countryId,
    String? regionId,
    required double itemsSubtotal,
    double promotionDiscount,
    double shippingCost,
  });
}