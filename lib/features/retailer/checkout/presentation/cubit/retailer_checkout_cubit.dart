import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_error_mapper.dart';
import '../../data/models/retailer_checkout_model.dart';
import '../../data/services/retailer_checkout_api_service.dart';
import 'retailer_checkout_state.dart';

class RetailerCheckoutCubit extends Cubit<RetailerCheckoutState> {
  final RetailerCheckoutApiService apiService;

  RetailerCheckoutCubit({required this.apiService})
    : super(const RetailerCheckoutState());

  Future<void> loadEligibleBranches() async {
    emit(
      state.copyWith(
        isLoadingBranches: true,
        clearError: true,
        clearSuccess: true,
        clearPreview: true,
        clearSelectedShippingMethodId: true,
      ),
    );

    try {
      final branches = await apiService.getEligibleBranches();

      final autoSelectedBranch = branches.length == 1 ? branches.first : null;

      emit(
        state.copyWith(
          isLoadingBranches: false,
          eligibleBranches: branches,
          selectedBranch: autoSelectedBranch,
          clearSelectedBranch: autoSelectedBranch == null,
          clearPreview: true,
          clearSelectedShippingMethodId: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingBranches: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  void selectBranch(RetailerEligibleCheckoutBranchModel branch) {
    emit(
      state.copyWith(
        selectedBranch: branch,
        clearPreview: true,
        clearSelectedShippingMethodId: true,
      ),
    );
  }

  Future<void> previewCheckout({
    required int branchId,
    required int countryId,
    required int? regionId,
    int? selectedShippingMethodId,
  }) async {
    emit(
      state.copyWith(
        isLoadingPreview: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final preview = await apiService.previewCheckout(
        request: RetailerCheckoutPreviewRequestModel(
          branchId: branchId,
          countryId: countryId,
          regionId: regionId,
          selectedShippingMethodId: selectedShippingMethodId,
        ),
      );

      final resolvedShippingMethodId =
          preview.selectedShippingMethod?.id ?? selectedShippingMethodId;

      final enabledPaymentMethods =
          preview.paymentMethods
              .where((method) => method.enabled && !method.comingSoon)
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final currentSelectedPaymentMethod = state.selectedPaymentMethod;

      final resolvedPaymentMethod =
          currentSelectedPaymentMethod != null &&
              enabledPaymentMethods.any(
                (method) => method.methodName == currentSelectedPaymentMethod,
              )
          ? currentSelectedPaymentMethod
          : enabledPaymentMethods.isEmpty
          ? null
          : enabledPaymentMethods.first.methodName;

      emit(
        state.copyWith(
          isLoadingPreview: false,
          preview: preview,
          selectedShippingMethodId: resolvedShippingMethodId,
          selectedPaymentMethod: resolvedPaymentMethod,
          clearSelectedPaymentMethod: resolvedPaymentMethod == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingPreview: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> selectShippingMethod({
    required int branchId,
    required int countryId,
    required int? regionId,
    required int shippingMethodId,
  }) async {
    emit(
      state.copyWith(
        selectedShippingMethodId: shippingMethodId,
        clearError: true,
        clearSuccess: true,
      ),
    );

    await previewCheckout(
      branchId: branchId,
      countryId: countryId,
      regionId: regionId,
      selectedShippingMethodId: shippingMethodId,
    );
  }

  void selectPaymentMethod(String paymentMethod) {
    emit(
      state.copyWith(
        selectedPaymentMethod: paymentMethod,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> placeOrder({
    required int branchId,
    required String deliveryAddress,
    required int deliveryCountryId,
    required int? deliveryRegionId,
    required int? shippingMethodId,
    required String paymentMethod,
    String? notes,
  }) async {
    emit(
      state.copyWith(
        isPlacingOrder: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final order = await apiService.createOrder(
        request: RetailerCreateCheckoutOrderRequestModel(
          branchId: branchId,
          deliveryAddress: deliveryAddress,
          deliveryCountryId: deliveryCountryId,
          deliveryRegionId: deliveryRegionId,
          shippingMethodId: shippingMethodId,
          paymentMethod: paymentMethod,
          notes: notes,
        ),
      );

      final payment = await apiService.startPayment(
        orderId: order.id,
        request: RetailerStartPaymentRequestModel(paymentMethod: paymentMethod),
      );

      emit(
        state.copyWith(
          isPlacingOrder: false,
          createdOrder: order,
          paymentResult: payment,
          successMessage: _successMessageForPayment(payment),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPlacingOrder: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  String _successMessageForPayment(RetailerCheckoutPaymentStartModel payment) {
    final method = payment.paymentMethod.toUpperCase();

    if (method == 'CASH') {
      return 'Order placed successfully. Cash payment is pending supplier confirmation.';
    }

    if (method == 'STRIPE') {
      return 'Order created. Stripe payment is ready to continue.';
    }

    if (method == 'MPGS') {
      return 'Order created. Card hosted checkout is ready to continue.';
    }

    return 'Order created successfully.';
  }
}
