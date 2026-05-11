import '../repositories/tax_rule_repository.dart';

class DeleteTaxRuleUseCase {
  final TaxRuleRepository repository;

  DeleteTaxRuleUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteTaxRule(id);
  }
}