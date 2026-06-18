
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_error_mapper.dart';
import '../../domain/usecases/create_shipping_method_usecase.dart';
import '../../domain/usecases/delete_shipping_method_usecase.dart';
import '../../domain/usecases/get_shipping_methods_usecase.dart';
import '../../domain/usecases/update_shipping_method_usecase.dart';
import 'shipping_methods_event.dart';
import 'shipping_methods_state.dart';

class ShippingMethodsBloc
    extends Bloc<ShippingMethodsEvent, ShippingMethodsState> {
  final GetShippingMethodsUseCase getShippingMethodsUseCase;
  final CreateShippingMethodUseCase createShippingMethodUseCase;
  final UpdateShippingMethodUseCase updateShippingMethodUseCase;
  final DeleteShippingMethodUseCase deleteShippingMethodUseCase;

  ShippingMethodsBloc({
    required this.getShippingMethodsUseCase,
    required this.createShippingMethodUseCase,
    required this.updateShippingMethodUseCase,
    required this.deleteShippingMethodUseCase,
  }) : super(const ShippingMethodsState()) {
    on<LoadShippingMethodsRequested>(_onLoadShippingMethodsRequested);
    on<CreateShippingMethodRequested>(_onCreateShippingMethodRequested);
    on<UpdateShippingMethodRequested>(_onUpdateShippingMethodRequested);
    on<DeleteShippingMethodRequested>(_onDeleteShippingMethodRequested);
    on<ClearShippingMethodMessageRequested>(
      _onClearShippingMethodMessageRequested,
    );
  }

  Future<void> _onLoadShippingMethodsRequested(
    LoadShippingMethodsRequested event,
    Emitter<ShippingMethodsState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final methods = await getShippingMethodsUseCase();

      emit(
        state.copyWith(
          loading: false,
          methods: methods,
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

  Future<void> _onCreateShippingMethodRequested(
    CreateShippingMethodRequested event,
    Emitter<ShippingMethodsState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await createShippingMethodUseCase(event.method);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'shippingMethodCreatedSuccessfully',
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

  Future<void> _onUpdateShippingMethodRequested(
    UpdateShippingMethodRequested event,
    Emitter<ShippingMethodsState> emit,
  ) async {
    emit(
      state.copyWith(
        saving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await updateShippingMethodUseCase(event.method);

      emit(
        state.copyWith(
          saving: false,
          successMessage: 'shippingMethodUpdatedSuccessfully',
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

  Future<void> _onDeleteShippingMethodRequested(
    DeleteShippingMethodRequested event,
    Emitter<ShippingMethodsState> emit,
  ) async {
    emit(
      state.copyWith(
        deleting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await deleteShippingMethodUseCase(event.id);

      final updatedMethods = state.methods
          .where((method) => method.id != event.id)
          .toList();

      emit(
        state.copyWith(
          deleting: false,
          methods: updatedMethods,
          successMessage: 'shippingMethodDeletedSuccessfully',
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

  void _onClearShippingMethodMessageRequested(
    ClearShippingMethodMessageRequested event,
    Emitter<ShippingMethodsState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}
