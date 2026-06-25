import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

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
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  /// Correct B2B MOQ behavior:
  /// - First add to cart = MOQ
  /// - After that, cart plus button increases by 1 only
  Future<void> increaseQuantity({
    required int cartItemId,
    required int currentQuantity,
    required int moq,
  }) async {
    final newQuantity = currentQuantity + 1;

    await _updateQuantity(cartItemId: cartItemId, quantity: newQuantity);
  }

  /// Correct B2B MOQ behavior:
  /// - Minus button decreases by 1 only
  /// - Quantity cannot go below MOQ
  Future<void> decreaseQuantity({
    required int cartItemId,
    required int currentQuantity,
    required int moq,
  }) async {
    final safeMoq = moq <= 0 ? 1 : moq;
    final newQuantity = currentQuantity - 1;

    if (newQuantity < safeMoq) return;

    await _updateQuantity(cartItemId: cartItemId, quantity: newQuantity);
  }

  /// Sets an exact quantity typed by the retailer.
  /// Quantity cannot go below MOQ.
  Future<void> setQuantity({
    required int cartItemId,
    required int quantity,
    required int moq,
  }) async {
    final safeMoq = moq <= 0 ? 1 : moq;
    final newQuantity = quantity < safeMoq ? safeMoq : quantity;

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
          errorMessage: AppErrorMapper.toMessage(e),
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
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
