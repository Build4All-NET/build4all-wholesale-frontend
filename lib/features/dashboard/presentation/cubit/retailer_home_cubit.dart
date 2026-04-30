import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/retailer_home_repository.dart';
import 'retailer_home_state.dart';

class RetailerHomeCubit extends Cubit<RetailerHomeState> {
  final RetailerHomeRepository retailerHomeRepository;

  RetailerHomeCubit({
    required this.retailerHomeRepository,
  }) : super(const RetailerHomeState());

  /// Loads complete Retailer Home data from Wholesale backend.
  Future<void> loadHome() async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final home = await retailerHomeRepository.getHome();

      emit(
        state.copyWith(
          isLoading: false,
          home: home,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Adds product to cart, then reloads home to refresh cart badge.
  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    emit(
      state.copyWith(
        isAddingToCart: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final response = await retailerHomeRepository.addToCart(
        productId: productId,
        quantity: quantity,
      );

      final updatedHome = await retailerHomeRepository.getHome();

      emit(
        state.copyWith(
          isAddingToCart: false,
          home: updatedHome,
          successMessage: response.message,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAddingToCart: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearMessages() {
    emit(
      state.copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}