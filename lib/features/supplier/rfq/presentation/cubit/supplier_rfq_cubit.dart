import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/supplier_rfq_request_entity.dart';
import '../../domain/repositories/supplier_rfq_repository.dart';
import '../../domain/usecases/get_open_supplier_rfqs_usecase.dart';
import '../../domain/usecases/get_supplier_rfq_details_usecase.dart';
import '../../domain/usecases/submit_supplier_rfq_quotation_usecase.dart';
import '../../domain/usecases/update_supplier_rfq_quotation_usecase.dart';
import '../../domain/usecases/withdraw_supplier_rfq_quotation_usecase.dart';
import 'supplier_rfq_state.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

class SupplierRfqCubit extends Cubit<SupplierRfqState> {
  final GetOpenSupplierRfqsUseCase getOpenSupplierRfqsUseCase;
  final GetSupplierRfqDetailsUseCase getSupplierRfqDetailsUseCase;
  final SubmitSupplierRfqQuotationUseCase submitSupplierRfqQuotationUseCase;
  final UpdateSupplierRfqQuotationUseCase updateSupplierRfqQuotationUseCase;
  final WithdrawSupplierRfqQuotationUseCase withdrawSupplierRfqQuotationUseCase;

  SupplierRfqCubit({
    required this.getOpenSupplierRfqsUseCase,
    required this.getSupplierRfqDetailsUseCase,
    required this.submitSupplierRfqQuotationUseCase,
    required this.updateSupplierRfqQuotationUseCase,
    required this.withdrawSupplierRfqQuotationUseCase,
  }) : super(const SupplierRfqState());

  Future<void> loadOpenRfqs() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final rfqs = await getOpenSupplierRfqsUseCase();
      emit(state.copyWith(isLoading: false, rfqs: rfqs));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: AppErrorMapper.toMessage(error)));
    }
  }

  Future<void> loadDetails(int rfqId) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final rfq = await getSupplierRfqDetailsUseCase(rfqId);
      emit(state.copyWith(isLoading: false, selectedRfq: rfq));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: AppErrorMapper.toMessage(error)));
    }
  }

  Future<SupplierRfqRequestEntity?> submitQuotation({
    required int rfqId,
    required SupplierQuotationParams params,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));

    try {
      await submitSupplierRfqQuotationUseCase(rfqId: rfqId, params: params);
      final updated = await getSupplierRfqDetailsUseCase(rfqId);

      emit(
        state.copyWith(
          isSubmitting: false,
          selectedRfq: updated,
          rfqs: _replaceInList(updated),
          successMessage: 'quotationSubmittedSuccessfully',
        ),
      );

      return updated;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: AppErrorMapper.toMessage(error)));
      return null;
    }
  }

  Future<SupplierRfqRequestEntity?> updateQuotation({
    required int quotationId,
    required SupplierQuotationParams params,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));

    try {
      await updateSupplierRfqQuotationUseCase(quotationId: quotationId, params: params);
      final currentRfqId = state.selectedRfq?.id;
      final updated = currentRfqId == null
          ? null
          : await getSupplierRfqDetailsUseCase(currentRfqId);

      emit(
        state.copyWith(
          isSubmitting: false,
          selectedRfq: updated,
          rfqs: updated == null ? state.rfqs : _replaceInList(updated),
          successMessage: 'quotationUpdatedSuccessfully',
        ),
      );

      return updated;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: AppErrorMapper.toMessage(error)));
      return null;
    }
  }

  Future<void> withdrawQuotation(int quotationId) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));

    try {
      final currentRfqId = state.selectedRfq?.id;
      await withdrawSupplierRfqQuotationUseCase(quotationId);
      final updated = currentRfqId == null
          ? null
          : await getSupplierRfqDetailsUseCase(currentRfqId);

      emit(
        state.copyWith(
          isSubmitting: false,
          selectedRfq: updated,
          rfqs: updated == null ? state.rfqs : _replaceInList(updated),
          successMessage: 'quotationWithdrawnSuccessfully',
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: AppErrorMapper.toMessage(error)));
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  List<SupplierRfqRequestEntity> _replaceInList(SupplierRfqRequestEntity updated) {
    final exists = state.rfqs.any((rfq) => rfq.id == updated.id);
    if (!exists) return [updated, ...state.rfqs];
    return state.rfqs.map((rfq) => rfq.id == updated.id ? updated : rfq).toList();
  }
}
