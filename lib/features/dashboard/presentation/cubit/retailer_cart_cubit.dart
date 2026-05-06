import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/retailer_cart_service.dart';
import 'retailer_cart_state.dart';

class RetailerCartCubit extends Cubit<RetailerCartState> {
  final RetailerCartService retailerCartService;

  RetailerCartCubit({required this.retailerCartService})
    : super(const RetailerCartState());

  Future<void> loadCart() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final cart = await retailerCartService.getCart();

      emit(state.copyWith(isLoading: false, cart: cart));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> increaseQuantity({
    required int cartItemId,
    required int currentQuantity,
    required int moq,
  }) async {
    final newQuantity = currentQuantity + moq;

    await _updateQuantity(cartItemId: cartItemId, quantity: newQuantity);
  }

  Future<void> decreaseQuantity({
    required int cartItemId,
    required int currentQuantity,
    required int moq,
  }) async {
    final newQuantity = currentQuantity - moq;

    if (newQuantity < moq) return;

    await _updateQuantity(cartItemId: cartItemId, quantity: newQuantity);
  }

  Future<void> _updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    emit(state.copyWith(updatingItemId: cartItemId, clearError: true));

    try {
      final cart = await retailerCartService.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      emit(state.copyWith(cart: cart, clearUpdatingItemId: true));
    } catch (e) {
      emit(
        state.copyWith(
          clearUpdatingItemId: true,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> deleteItem({required int cartItemId}) async {
    emit(state.copyWith(updatingItemId: cartItemId, clearError: true));

    try {
      final cart = await retailerCartService.deleteItem(cartItemId: cartItemId);

      emit(state.copyWith(cart: cart, clearUpdatingItemId: true));
    } catch (e) {
      emit(
        state.copyWith(
          clearUpdatingItemId: true,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
