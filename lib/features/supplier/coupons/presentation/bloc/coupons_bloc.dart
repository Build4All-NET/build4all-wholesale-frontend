import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_coupon_usecase.dart';
import '../../domain/usecases/delete_coupon_usecase.dart';
import '../../domain/usecases/get_coupons_usecase.dart';
import '../../domain/usecases/update_coupon_usecase.dart';
import 'coupons_event.dart';
import 'coupons_state.dart';

class CouponsBloc extends Bloc<CouponsEvent, CouponsState> {
  final GetCouponsUseCase getCouponsUseCase;
  final CreateCouponUseCase createCouponUseCase;
  final UpdateCouponUseCase updateCouponUseCase;
  final DeleteCouponUseCase deleteCouponUseCase;

  CouponsBloc({
    required this.getCouponsUseCase,
    required this.createCouponUseCase,
    required this.updateCouponUseCase,
    required this.deleteCouponUseCase,
  }) : super(const CouponsState()) {
    on<LoadCouponsRequested>(_onLoadCouponsRequested);
    on<CreateCouponRequested>(_onCreateCouponRequested);
    on<UpdateCouponRequested>(_onUpdateCouponRequested);
    on<DeleteCouponRequested>(_onDeleteCouponRequested);
    on<ClearCouponMessageRequested>(_onClearCouponMessageRequested);
  }

  Future<void> _onLoadCouponsRequested(
    LoadCouponsRequested event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final coupons = await getCouponsUseCase();

      emit(
        state.copyWith(
          loading: false,
          coupons: coupons,
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

  Future<void> _onCreateCouponRequested(
    CreateCouponRequested event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await createCouponUseCase(event.coupon);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'Coupon created successfully',
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

  Future<void> _onUpdateCouponRequested(
    UpdateCouponRequested event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await updateCouponUseCase(event.coupon);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'Coupon updated successfully',
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

  Future<void> _onDeleteCouponRequested(
    DeleteCouponRequested event,
    Emitter<CouponsState> emit,
  ) async {
    emit(
      state.copyWith(
        deleting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await deleteCouponUseCase(event.couponId);

      final updatedCoupons = state.coupons
          .where((coupon) => coupon.id != event.couponId)
          .toList();

      emit(
        state.copyWith(
          deleting: false,
          coupons: updatedCoupons,
          successMessage: 'Coupon deleted successfully',
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

  void _onClearCouponMessageRequested(
    ClearCouponMessageRequested event,
    Emitter<CouponsState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}