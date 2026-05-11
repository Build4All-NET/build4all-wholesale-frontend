import 'package:equatable/equatable.dart';

import '../../domain/entities/tax_rule_entity.dart';

abstract class TaxRulesEvent extends Equatable {
  const TaxRulesEvent();

  @override
  List<Object?> get props => [];
}

class LoadTaxRulesRequested extends TaxRulesEvent {
  const LoadTaxRulesRequested();
}

class CreateTaxRuleRequested extends TaxRulesEvent {
  final TaxRuleEntity rule;

  const CreateTaxRuleRequested(this.rule);

  @override
  List<Object?> get props => [rule];
}

class UpdateTaxRuleRequested extends TaxRulesEvent {
  final TaxRuleEntity rule;

  const UpdateTaxRuleRequested(this.rule);

  @override
  List<Object?> get props => [rule];
}

class DeleteTaxRuleRequested extends TaxRulesEvent {
  final String id;

  const DeleteTaxRuleRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearTaxRuleMessageRequested extends TaxRulesEvent {
  const ClearTaxRuleMessageRequested();
}