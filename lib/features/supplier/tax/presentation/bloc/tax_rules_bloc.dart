import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_tax_rule_usecase.dart';
import '../../domain/usecases/delete_tax_rule_usecase.dart';
import '../../domain/usecases/get_tax_rules_usecase.dart';
import '../../domain/usecases/update_tax_rule_usecase.dart';
import 'tax_rules_event.dart';
import 'tax_rules_state.dart';

class TaxRulesBloc extends Bloc<TaxRulesEvent, TaxRulesState> {
  final GetTaxRulesUseCase getTaxRulesUseCase;
  final CreateTaxRuleUseCase createTaxRuleUseCase;
  final UpdateTaxRuleUseCase updateTaxRuleUseCase;
  final DeleteTaxRuleUseCase deleteTaxRuleUseCase;

  TaxRulesBloc({
    required this.getTaxRulesUseCase,
    required this.createTaxRuleUseCase,
    required this.updateTaxRuleUseCase,
    required this.deleteTaxRuleUseCase,
  }) : super(const TaxRulesState()) {
    on<LoadTaxRulesRequested>(_onLoadTaxRulesRequested);
    on<CreateTaxRuleRequested>(_onCreateTaxRuleRequested);
    on<UpdateTaxRuleRequested>(_onUpdateTaxRuleRequested);
    on<DeleteTaxRuleRequested>(_onDeleteTaxRuleRequested);
    on<ClearTaxRuleMessageRequested>(_onClearTaxRuleMessageRequested);
  }

  Future<void> _onLoadTaxRulesRequested(
    LoadTaxRulesRequested event,
    Emitter<TaxRulesState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final rules = await getTaxRulesUseCase();

      emit(
        state.copyWith(
          loading: false,
          rules: rules,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateTaxRuleRequested(
    CreateTaxRuleRequested event,
    Emitter<TaxRulesState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await createTaxRuleUseCase(event.rule);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'Tax rule created successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateTaxRuleRequested(
    UpdateTaxRuleRequested event,
    Emitter<TaxRulesState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await updateTaxRuleUseCase(event.rule);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'Tax rule updated successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteTaxRuleRequested(
    DeleteTaxRuleRequested event,
    Emitter<TaxRulesState> emit,
  ) async {
    emit(
      state.copyWith(
        deleting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await deleteTaxRuleUseCase(event.id);

      final updatedRules = state.rules
          .where((rule) => rule.id != event.id)
          .toList();

      emit(
        state.copyWith(
          deleting: false,
          rules: updatedRules,
          successMessage: 'Tax rule deleted successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          deleting: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onClearTaxRuleMessageRequested(
    ClearTaxRuleMessageRequested event,
    Emitter<TaxRulesState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}