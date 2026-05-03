import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/retailer_home_repository.dart';
import 'retailer_home_state.dart';
import '../../data/models/retailer_home_model.dart';

class RetailerHomeCubit extends Cubit<RetailerHomeState> {
  final RetailerHomeRepository retailerHomeRepository;

  RetailerHomeCubit({required this.retailerHomeRepository})
    : super(const RetailerHomeState());

  /// Loads all Retailer Home data:
  /// - welcome name
  /// - banners
  /// - categories
  /// - featured products
  /// - cart count
  /// - notifications count
  Future<void> loadHome() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final home = await retailerHomeRepository.getHome();

      emit(state.copyWith(isLoading: false, home: home));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Adds only the selected product to the cart.
  ///
  /// Important:
  /// We store [addingProductId] instead of using one global loading bool.
  /// This prevents all Add buttons from showing loading at the same time.
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

      final refreshedHome = await retailerHomeRepository.getHome();

      emit(
        state.copyWith(
          clearAddingProductId: true,
          home: refreshedHome,
          successMessage: 'Product added to cart',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          clearAddingProductId: true,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Clears snack-bar messages after they are shown.
  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
