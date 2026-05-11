import '../entities/tax_rule_entity.dart';
import '../repositories/tax_rule_repository.dart';

class UpdateTaxRuleUseCase {
  final TaxRuleRepository repository;

  UpdateTaxRuleUseCase(this.repository);

  Future<TaxRuleEntity> call(TaxRuleEntity rule) {
    return repository.updateTaxRule(rule);
  }
}