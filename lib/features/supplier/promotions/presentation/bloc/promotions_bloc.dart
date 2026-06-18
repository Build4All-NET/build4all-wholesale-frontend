import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_error_mapper.dart';
import '../../domain/usecases/create_promotion_usecase.dart';
import '../../domain/usecases/delete_promotion_usecase.dart';
import '../../domain/usecases/get_promotions_usecase.dart';
import '../../domain/usecases/update_promotion_usecase.dart';
import 'promotions_event.dart';
import 'promotions_state.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final GetPromotionsUseCase getPromotionsUseCase;
  final CreatePromotionUseCase createPromotionUseCase;
  final UpdatePromotionUseCase updatePromotionUseCase;
  final DeletePromotionUseCase deletePromotionUseCase;

  PromotionsBloc({
    required this.getPromotionsUseCase,
    required this.createPromotionUseCase,
    required this.updatePromotionUseCase,
    required this.deletePromotionUseCase,
  }) : super(const PromotionsState()) {
    on<LoadPromotionsRequested>(_onLoadPromotionsRequested);
    on<CreatePromotionRequested>(_onCreatePromotionRequested);
    on<UpdatePromotionRequested>(_onUpdatePromotionRequested);
    on<DeletePromotionRequested>(_onDeletePromotionRequested);
    on<ClearPromotionMessageRequested>(_onClearPromotionMessageRequested);
  }

  Future<void> _onLoadPromotionsRequested(
    LoadPromotionsRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final promotions = await getPromotionsUseCase();

      emit(
        state.copyWith(
          loading: false,
          promotions: promotions,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> _onCreatePromotionRequested(
    CreatePromotionRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await createPromotionUseCase(event.promotion);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'promotionCreatedSuccessfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> _onUpdatePromotionRequested(
    UpdatePromotionRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await updatePromotionUseCase(event.promotion);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'promotionUpdatedSuccessfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> _onDeletePromotionRequested(
    DeletePromotionRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(
      state.copyWith(
        deleting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await deletePromotionUseCase(event.promotionId);

      final updatedPromotions = state.promotions
          .where((promotion) => promotion.id != event.promotionId)
          .toList();

      emit(
        state.copyWith(
          deleting: false,
          promotions: updatedPromotions,
          successMessage: 'promotionDeletedSuccessfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          deleting: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  void _onClearPromotionMessageRequested(
    ClearPromotionMessageRequested event,
    Emitter<PromotionsState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}