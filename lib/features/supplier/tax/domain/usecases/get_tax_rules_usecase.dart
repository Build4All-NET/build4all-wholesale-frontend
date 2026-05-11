import '../entities/tax_rule_entity.dart';
import '../repositories/tax_rule_repository.dart';

class GetTaxRulesUseCase {
  final TaxRuleRepository repository;

  GetTaxRulesUseCase(this.repository);

  Future<List<TaxRuleEntity>> call() {
    return repository.getTaxRules();
  }
}