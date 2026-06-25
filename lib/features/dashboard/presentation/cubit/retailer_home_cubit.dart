import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../data/models/retailer_home_model.dart';
import '../../domain/repositories/retailer_home_repository.dart';
import 'retailer_home_state.dart';

class RetailerHomeCubit extends Cubit<RetailerHomeState> {
  final RetailerHomeRepository retailerHomeRepository;

  RetailerHomeCubit({required this.retailerHomeRepository})
    : super(const RetailerHomeState());

  Future<void> loadHome() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final home = await retailerHomeRepository.getHome();

      emit(state.copyWith(isLoading: false, home: home));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadProductsByCategory({
    required HomeCategoryModel category,
  }) async {
    emit(
      state.copyWith(
        isCategoryProductsLoading: true,
        selectedCategory: category,
        categoryProducts: const [],
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final products = await retailerHomeRepository.getProductsByCategory(
        categoryId: category.id,
      );

      emit(
        state.copyWith(
          isCategoryProductsLoading: false,
          categoryProducts: products,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isCategoryProductsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadPromotedProducts() async {
    emit(
      state.copyWith(
        isPromotionsLoading: true,
        promotedProducts: const [],
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final products = await retailerHomeRepository.getPromotedProducts();

      emit(
        state.copyWith(
          isPromotionsLoading: false,
          promotedProducts: products,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPromotionsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> searchProducts({required String query}) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      emit(
        state.copyWith(
          isSearchLoading: false,
          searchResults: const [],
          searchQuery: '',
          hasSearched: false,
          clearError: true,
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSearchLoading: true,
        searchQuery: trimmedQuery,
        hasSearched: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final results = await retailerHomeRepository.searchProducts(
        query: trimmedQuery,
      );

      // Ignore stale responses if the query changed while the request was in flight.
      if (state.searchQuery != trimmedQuery) return;

      emit(state.copyWith(isSearchLoading: false, searchResults: results));
    } catch (e) {
      if (state.searchQuery != trimmedQuery) return;

      emit(
        state.copyWith(
          isSearchLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> addToCart({required HomeProductModel product, int? quantity}) async {
    emit(
      state.copyWith(
        addingProductId: product.id,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await retailerHomeRepository.addToCart(
        product: product,
        quantity: quantity,
      );

      RetailerHomeModel? refreshedHome;
      if (state.home != null) {
        refreshedHome = await retailerHomeRepository.getHome();
      }

      emit(
        state.copyWith(
          clearAddingProductId: true,
          home: refreshedHome,
          successMessage: 'PRODUCT_ADDED_TO_CART',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          clearAddingProductId: true,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
