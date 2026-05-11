import '../../domain/entities/tax_preview_entity.dart';
import '../../domain/entities/tax_rule_entity.dart';
import '../../domain/repositories/tax_rule_repository.dart';
import '../models/tax_rule_model.dart';
import '../services/tax_rule_api_service.dart';

class TaxRuleRepositoryImpl implements TaxRuleRepository {
  final TaxRuleApiService apiService;

  TaxRuleRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<TaxRuleEntity>> getTaxRules() async {
    final models = await apiService.getTaxRules();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<TaxRuleEntity> createTaxRule(TaxRuleEntity rule) async {
    final model = TaxRuleModel.fromEntity(rule);
    final created = await apiService.createTaxRule(model);
    return created.toEntity();
  }

  @override
  Future<TaxRuleEntity> updateTaxRule(TaxRuleEntity rule) async {
    final model = TaxRuleModel.fromEntity(rule);
    final updated = await apiService.updateTaxRule(model);
    return updated.toEntity();
  }

  @override
  Future<void> deleteTaxRule(String id) {
    return apiService.deleteTaxRule(id);
  }

  @override
  Future<TaxPreviewEntity> previewTax({
    required String countryId,
    String? regionId,
    required double itemsSubtotal,
    double promotionDiscount = 0,
    double shippingCost = 0,
  }) {
    return apiService.previewTax(
      countryId: countryId,
      regionId: regionId,
      itemsSubtotal: itemsSubtotal,
      promotionDiscount: promotionDiscount,
      shippingCost: shippingCost,
    );
  }
}