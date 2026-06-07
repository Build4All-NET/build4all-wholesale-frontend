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

  Future<void> addToCart({required HomeProductModel product}) async {
    emit(
      state.copyWith(
        addingProductId: product.id,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await retailerHomeRepository.addToCart(product: product);

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
