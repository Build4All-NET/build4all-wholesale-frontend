import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../products/domain/usecases/get_products_usecase.dart';
import '../../../domain/usecases/assign_product_to_branch_usecase.dart';
import '../../../domain/usecases/delete_inventory_item_usecase.dart';
import '../../../domain/usecases/get_inventory_by_branch_usecase.dart';
import '../../../domain/usecases/update_branch_stock_usecase.dart';
import 'branch_inventory_event.dart';
import 'branch_inventory_state.dart';

class BranchInventoryBloc
    extends Bloc<BranchInventoryEvent, BranchInventoryState> {
  final GetInventoryByBranchUseCase getInventoryByBranchUseCase;
  final GetProductsUseCase getProductsUseCase;
  final AssignProductToBranchUseCase assignProductToBranchUseCase;
  final UpdateBranchStockUseCase updateBranchStockUseCase;
  final DeleteInventoryItemUseCase deleteInventoryItemUseCase;

  BranchInventoryBloc({
    required this.getInventoryByBranchUseCase,
    required this.getProductsUseCase,
    required this.assignProductToBranchUseCase,
    required this.updateBranchStockUseCase,
    required this.deleteInventoryItemUseCase,
  }) : super(BranchInventoryState.initial()) {
    on<LoadBranchInventory>(_onLoadBranchInventory);
    on<AssignProductToBranchRequested>(_onAssignProductToBranchRequested);
    on<UpdateBranchInventoryStockRequested>(
      _onUpdateBranchInventoryStockRequested,
    );
    on<DeleteBranchInventoryItemRequested>(
      _onDeleteBranchInventoryItemRequested,
    );
  }

  Future<void> _onLoadBranchInventory(
    LoadBranchInventory event,
    Emitter<BranchInventoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final inventoryItems = await getInventoryByBranchUseCase(
        branchId: event.branchId,
      );

      final products = await getProductsUseCase();

      emit(
        state.copyWith(
          isLoading: false,
          inventoryItems: inventoryItems,
          products: products,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAssignProductToBranchRequested(
    AssignProductToBranchRequested event,
    Emitter<BranchInventoryState> emit,
  ) async {
    emit(state.copyWith(isAssigning: true, clearMessages: true));

    try {
      await assignProductToBranchUseCase(
        branchId: event.branchId,
        productId: event.productId,
        stockQuantity: event.stockQuantity,
      );

      final inventoryItems = await getInventoryByBranchUseCase(
        branchId: event.branchId,
      );

      final products = await getProductsUseCase();

      emit(
        state.copyWith(
          isAssigning: false,
          inventoryItems: inventoryItems,
          products: products,
          successMessage: 'Product assigned to branch',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAssigning: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onUpdateBranchInventoryStockRequested(
    UpdateBranchInventoryStockRequested event,
    Emitter<BranchInventoryState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearMessages: true));

    try {
      await updateBranchStockUseCase(
        inventoryId: event.inventoryId,
        stockQuantity: event.stockQuantity,
      );

      final inventoryItems = await getInventoryByBranchUseCase(
        branchId: event.branchId,
      );

      emit(
        state.copyWith(
          isUpdating: false,
          inventoryItems: inventoryItems,
          successMessage: 'Stock updated',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onDeleteBranchInventoryItemRequested(
    DeleteBranchInventoryItemRequested event,
    Emitter<BranchInventoryState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, clearMessages: true));

    try {
      await deleteInventoryItemUseCase(
        inventoryId: event.inventoryId,
      );

      final inventoryItems = await getInventoryByBranchUseCase(
        branchId: event.branchId,
      );

      emit(
        state.copyWith(
          isDeleting: false,
          inventoryItems: inventoryItems,
          successMessage: 'Inventory item removed',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}