import '../entities/tax_rule_entity.dart';
import '../repositories/tax_rule_repository.dart';

class CreateTaxRuleUseCase {
  final TaxRuleRepository repository;

  CreateTaxRuleUseCase(this.repository);

  Future<TaxRuleEntity> call(TaxRuleEntity rule) {
    return repository.createTaxRule(rule);
  }
}