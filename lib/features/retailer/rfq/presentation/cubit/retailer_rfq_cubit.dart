import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../domain/entities/rfq_request_entity.dart';
import '../../domain/repositories/retailer_rfq_repository.dart';
import '../../domain/usecases/accept_rfq_quotation_usecase.dart';
import '../../domain/usecases/cancel_rfq_usecase.dart';
import '../../domain/usecases/create_rfq_usecase.dart';
import '../../domain/usecases/delete_rfq_usecase.dart';
import '../../domain/usecases/generate_rfq_requirements_usecase.dart';
import '../../domain/usecases/get_my_rfqs_usecase.dart';
import '../../domain/usecases/get_rfq_details_usecase.dart';
import '../../domain/usecases/update_rfq_usecase.dart';
import 'retailer_rfq_state.dart';

class RetailerRfqCubit extends Cubit<RetailerRfqState> {
  final GetMyRfqsUseCase getMyRfqsUseCase;
  final GetRfqDetailsUseCase getRfqDetailsUseCase;
  final CreateRfqUseCase createRfqUseCase;
  final UpdateRfqUseCase updateRfqUseCase;
  final CancelRfqUseCase cancelRfqUseCase;
  final DeleteRfqUseCase deleteRfqUseCase;
  final AcceptRfqQuotationUseCase acceptRfqQuotationUseCase;
  final GenerateRfqRequirementsUseCase generateRfqRequirementsUseCase;

  RetailerRfqCubit({
    required this.getMyRfqsUseCase,
    required this.getRfqDetailsUseCase,
    required this.createRfqUseCase,
    required this.updateRfqUseCase,
    required this.cancelRfqUseCase,
    required this.deleteRfqUseCase,
    required this.acceptRfqQuotationUseCase,
    required this.generateRfqRequirementsUseCase,
  }) : super(const RetailerRfqState());

  Future<void> loadMyRfqs() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final rfqs = await getMyRfqsUseCase();

      emit(state.copyWith(isLoading: false, rfqs: rfqs));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: AppErrorMapper.toMessage(error)));
    }
  }

  Future<void> loadDetails(int rfqId) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final rfq = await getRfqDetailsUseCase(rfqId);

      emit(state.copyWith(isLoading: false, selectedRfq: rfq));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: AppErrorMapper.toMessage(error)));
    }
  }

  Future<RfqRequestEntity?> createRfq(CreateRfqParams params) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));

    try {
      final created = await createRfqUseCase(params);

      final updatedList = [created, ...state.rfqs];

      emit(
        state.copyWith(
          isSubmitting: false,
          rfqs: updatedList,
          selectedRfq: created,
          successMessage: 'RFQ posted successfully',
        ),
      );

      return created;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: AppErrorMapper.toMessage(error)));

      return null;
    }
  }

  Future<RfqRequestEntity?> updateRfq({
    required int rfqId,
    required UpdateRfqParams params,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));

    try {
      final updated = await updateRfqUseCase(rfqId: rfqId, params: params);

      emit(
        state.copyWith(
          isSubmitting: false,
          selectedRfq: updated,
          rfqs: _replaceInList(updated),
          successMessage: 'RFQ updated successfully',
        ),
      );

      return updated;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: AppErrorMapper.toMessage(error)));

      return null;
    }
  }

  Future<String?> generateRequirementsWithAi(
    GenerateRfqRequirementsParams params,
  ) async {
    emit(
      state.copyWith(
        isAiWriting: true,
        clearMessages: true,
        clearAiGeneratedRequirements: true,
      ),
    );

    try {
      final requirements = await generateRfqRequirementsUseCase(params);

      emit(
        state.copyWith(
          isAiWriting: false,
          aiGeneratedRequirements: requirements,
          successMessage: 'AI requirements generated successfully',
        ),
      );

      return requirements;
    } catch (error) {
      emit(state.copyWith(isAiWriting: false, errorMessage: AppErrorMapper.toMessage(error)));

      return null;
    }
  }

  Future<void> cancelRfq(int rfqId) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));

    try {
      final updated = await cancelRfqUseCase(rfqId);

      emit(
        state.copyWith(
          isSubmitting: false,
          selectedRfq: updated,
          rfqs: _replaceInList(updated),
          successMessage: 'RFQ cancelled successfully',
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: AppErrorMapper.toMessage(error)));
    }
  }

  Future<void> deleteRfq(int rfqId) async {
    emit(state.copyWith(isDeleting: true, clearMessages: true));

    try {
      await deleteRfqUseCase(rfqId);

      emit(
        state.copyWith(
          isDeleting: false,
          rfqs: state.rfqs.where((rfq) => rfq.id != rfqId).toList(),
          clearSelectedRfq: true,
          successMessage: 'RFQ deleted successfully',
        ),
      );
    } catch (error) {
      emit(state.copyWith(isDeleting: false, errorMessage: AppErrorMapper.toMessage(error)));
    }
  }

  Future<void> acceptQuotation({
    required int rfqId,
    required int quotationId,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));

    try {
      final updated = await acceptRfqQuotationUseCase(
        rfqId: rfqId,
        quotationId: quotationId,
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          selectedRfq: updated,
          rfqs: _replaceInList(updated),
          successMessage: 'Quotation accepted successfully',
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: AppErrorMapper.toMessage(error)));
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  List<RfqRequestEntity> _replaceInList(RfqRequestEntity updated) {
    final exists = state.rfqs.any((rfq) => rfq.id == updated.id);

    if (!exists) {
      return [updated, ...state.rfqs];
    }

    return state.rfqs
        .map((rfq) => rfq.id == updated.id ? updated : rfq)
        .toList();
  }
}
