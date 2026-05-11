import '../entities/tax_preview_entity.dart';
import '../repositories/tax_rule_repository.dart';

class PreviewTaxUseCase {
  final TaxRuleRepository repository;

  PreviewTaxUseCase(this.repository);

  Future<TaxPreviewEntity> call({
    required String countryId,
    String? regionId,
    required double itemsSubtotal,
    double promotionDiscount = 0,
    double shippingCost = 0,
  }) {
    return repository.previewTax(
      countryId: countryId,
      regionId: regionId,
      itemsSubtotal: itemsSubtotal,
      promotionDiscount: promotionDiscount,
      shippingCost: shippingCost,
    );
  }
}