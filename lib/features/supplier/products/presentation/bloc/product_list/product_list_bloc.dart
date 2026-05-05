import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/delete_product_usecase.dart';
import '../../../domain/usecases/get_products_usecase.dart';
import '../../../domain/usecases/search_products_usecase.dart';
import 'product_list_event.dart';
import 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final GetProductsUseCase getProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductListBloc({
    required this.getProductsUseCase,
    required this.searchProductsUseCase,
    required this.deleteProductUseCase,
  }) : super(ProductListState.initial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<DeleteProductRequested>(_onDeleteProductRequested);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    try {
      final products = await getProductsUseCase();

      emit(
        state.copyWith(
          isLoading: false,
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

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      final products = event.query.trim().isEmpty
          ? await getProductsUseCase()
          : await searchProductsUseCase(query: event.query);

      emit(
        state.copyWith(
          products: products,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onDeleteProductRequested(
    DeleteProductRequested event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, clearMessages: true));

    try {
      await deleteProductUseCase(productId: event.productId);

      final updatedProducts = state.products
          .where((product) => product.id != event.productId)
          .toList();

      emit(
        state.copyWith(
          isDeleting: false,
          products: updatedProducts,
          successMessage: 'Product deleted',
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