import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_supplier_profile_display_usecase.dart';
import 'supplier_profile_display_event.dart';
import 'supplier_profile_display_state.dart';

class SupplierProfileDisplayBloc
    extends Bloc<SupplierProfileDisplayEvent, SupplierProfileDisplayState> {
  final GetSupplierProfileDisplayUseCase getSupplierProfileDisplayUseCase;

  SupplierProfileDisplayBloc({
    required this.getSupplierProfileDisplayUseCase,
  }) : super(SupplierProfileDisplayState()) {
    on<LoadSupplierProfileDisplayRequested>(_onLoadRequested);
    on<RefreshSupplierProfileDisplayRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    LoadSupplierProfileDisplayRequested event,
    Emitter<SupplierProfileDisplayState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
      ),
    );

    try {
      final profile = await getSupplierProfileDisplayUseCase();

      emit(
        state.copyWith(
          loading: false,
          profile: profile,
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

  Future<void> _onRefreshRequested(
    RefreshSupplierProfileDisplayRequested event,
    Emitter<SupplierProfileDisplayState> emit,
  ) async {
    emit(
      state.copyWith(
        refreshing: true,
        clearError: true,
      ),
    );

    try {
      final profile = await getSupplierProfileDisplayUseCase();

      emit(
        state.copyWith(
          refreshing: false,
          profile: profile,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          refreshing: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
