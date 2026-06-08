import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../../../branches/domain/usecases/assign_product_to_branch_usecase.dart';
import '../../../../branches/domain/usecases/delete_inventory_item_usecase.dart';
import '../../../../branches/domain/usecases/get_branches_usecase.dart';
import '../../../../branches/domain/usecases/get_inventory_by_product_usecase.dart';
import '../../../../branches/domain/usecases/update_branch_stock_usecase.dart';
import 'product_branch_inventory_event.dart';
import 'product_branch_inventory_state.dart';

class ProductBranchInventoryBloc
    extends Bloc<ProductBranchInventoryEvent, ProductBranchInventoryState> {
  final GetBranchesUseCase getBranchesUseCase;
  final GetInventoryByProductUseCase getInventoryByProductUseCase;
  final AssignProductToBranchUseCase assignProductToBranchUseCase;
  final UpdateBranchStockUseCase updateBranchStockUseCase;
  final DeleteInventoryItemUseCase deleteInventoryItemUseCase;

  ProductBranchInventoryBloc({
    required this.getBranchesUseCase,
    required this.getInventoryByProductUseCase,
    required this.assignProductToBranchUseCase,
    required this.updateBranchStockUseCase,
    required this.deleteInventoryItemUseCase,
  }) : super(ProductBranchInventoryState.initial()) {
    on<LoadProductBranchInventory>(_onLoadProductBranchInventory);
    on<AssignProductStockToBranchRequested>(
      _onAssignProductStockToBranchRequested,
    );
    on<UpdateProductBranchStockRequested>(
      _onUpdateProductBranchStockRequested,
    );
    on<DeleteProductBranchInventoryItemRequested>(
      _onDeleteProductBranchInventoryItemRequested,
    );
  }

  Future<void> _onLoadProductBranchInventory(
    LoadProductBranchInventory event,
    Emitter<ProductBranchInventoryState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        product: event.product,
        clearMessages: true,
      ),
    );

    try {
      final branches = await getBranchesUseCase();
      final productInventory = await getInventoryByProductUseCase(
        productId: event.product.id,
      );

      emit(
        state.copyWith(
          isLoading: false,
          product: event.product,
          branches: branches,
          productInventory: productInventory,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> _onAssignProductStockToBranchRequested(
    AssignProductStockToBranchRequested event,
    Emitter<ProductBranchInventoryState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await assignProductToBranchUseCase(
        branchId: event.branchId,
        productId: event.product.id,
        stockQuantity: event.stockQuantity,
      );

      final branches = await getBranchesUseCase();
      final productInventory = await getInventoryByProductUseCase(
        productId: event.product.id,
      );

      emit(
        state.copyWith(
          isSaving: false,
          product: event.product,
          branches: branches,
          productInventory: productInventory,
          successMessage: 'stockAssigned',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          error: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> _onUpdateProductBranchStockRequested(
    UpdateProductBranchStockRequested event,
    Emitter<ProductBranchInventoryState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));

    try {
      await updateBranchStockUseCase(
        inventoryId: event.inventoryId,
        stockQuantity: event.stockQuantity,
      );

      final productInventory = await getInventoryByProductUseCase(
        productId: event.product.id,
      );

      emit(
        state.copyWith(
          isSaving: false,
          product: event.product,
          productInventory: productInventory,
          successMessage: 'stockUpdated',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          error: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> _onDeleteProductBranchInventoryItemRequested(
    DeleteProductBranchInventoryItemRequested event,
    Emitter<ProductBranchInventoryState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, clearMessages: true));

    try {
      await deleteInventoryItemUseCase(
        inventoryId: event.inventoryId,
      );

      final productInventory = await getInventoryByProductUseCase(
        productId: event.product.id,
      );

      emit(
        state.copyWith(
          isDeleting: false,
          product: event.product,
          productInventory: productInventory,
          successMessage: 'inventoryItemRemoved',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          error: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }
}