import 'package:equatable/equatable.dart';

import '../../domain/entities/tax_rule_entity.dart';

class TaxRulesState extends Equatable {
  final bool loading;
  final bool saving;
  final bool deleting;
  final List<TaxRuleEntity> rules;
  final String? errorMessage;
  final String? successMessage;

  const TaxRulesState({
    this.loading = false,
    this.saving = false,
    this.deleting = false,
    this.rules = const [],
    this.errorMessage,
    this.successMessage,
  });

  TaxRulesState copyWith({
    bool? loading,
    bool? saving,
    bool? deleting,
    List<TaxRuleEntity>? rules,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TaxRulesState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      deleting: deleting ?? this.deleting,
      rules: rules ?? this.rules,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        saving,
        deleting,
        rules,
        errorMessage,
        successMessage,
      ];
}