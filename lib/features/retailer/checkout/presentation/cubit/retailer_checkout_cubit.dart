import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_error_mapper.dart';
import '../../data/models/retailer_checkout_model.dart';
import '../../data/models/retailer_split_checkout_model.dart';
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
        clearSplitPreview: true,
        clearSelectedShippingMethodId: true,
        clearSplitCheckoutResult: true,
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
          clearSplitPreview: true,
          clearSelectedShippingMethodId: true,
          clearSplitCheckoutResult: true,
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
        clearSplitPreview: true,
        clearSelectedShippingMethodId: true,
        clearSplitCheckoutResult: true,
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

      final resolvedPaymentMethod = _resolvePaymentMethod(
        paymentMethods: preview.paymentMethods,
        currentSelectedPaymentMethod: state.selectedPaymentMethod,
      );

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

  Future<void> previewSplitCheckout({
    required int deliveryCountryId,
    required int? deliveryRegionId,
    bool resetShippingSelections = false,
  }) async {
    emit(
      state.copyWith(
        isLoadingSplitPreview: true,
        selectedSplitShippingMethodIds: resetShippingSelections
            ? const <int, int?>{}
            : state.selectedSplitShippingMethodIds,
        clearError: true,
        clearSuccess: true,
        clearSplitCheckoutResult: true,
      ),
    );

    try {
      final preview = await apiService.splitPreviewCheckout(
        request: RetailerSplitCheckoutPreviewRequestModel(
          deliveryCountryId: deliveryCountryId,
          deliveryRegionId: deliveryRegionId,
          shippingSelections: resetShippingSelections
              ? const []
              : _shippingSelectionsFromState(),
        ),
      );

      final resolvedShippingSelections = _shippingSelectionsFromPreview(preview);
      final resolvedPaymentMethod = _resolvePaymentMethod(
        paymentMethods: preview.paymentMethods,
        currentSelectedPaymentMethod: state.selectedPaymentMethod,
      );

      emit(
        state.copyWith(
          isLoadingSplitPreview: false,
          splitPreview: preview,
          selectedSplitShippingMethodIds: resolvedShippingSelections,
          selectedPaymentMethod: resolvedPaymentMethod,
          clearSelectedPaymentMethod: resolvedPaymentMethod == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingSplitPreview: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> selectSplitShippingMethod({
    required int branchId,
    required int? shippingMethodId,
    required int deliveryCountryId,
    required int? deliveryRegionId,
  }) async {
    final updatedSelections = Map<int, int?>.from(
      state.selectedSplitShippingMethodIds,
    );
    updatedSelections[branchId] = shippingMethodId;

    emit(
      state.copyWith(
        selectedSplitShippingMethodIds: updatedSelections,
        clearError: true,
        clearSuccess: true,
        clearSplitCheckoutResult: true,
      ),
    );

    await previewSplitCheckout(
      deliveryCountryId: deliveryCountryId,
      deliveryRegionId: deliveryRegionId,
    );
  }

  void resetSplitDeliverySelections() {
    emit(
      state.copyWith(
        selectedSplitShippingMethodIds: const <int, int?>{},
        clearError: true,
        clearSuccess: true,
        clearSplitPreview: true,
        clearSplitCheckoutResult: true,
      ),
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
          successMessage: _shouldWaitForOnlinePayment(payment)
              ? null
              : _successMessageForPayment(payment),
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

  Future<void> placeSplitCheckout({
    required String deliveryAddress,
    required int deliveryCountryId,
    required int? deliveryRegionId,
    required String paymentMethod,
    String? notes,
  }) async {
    emit(
      state.copyWith(
        isPlacingOrder: true,
        clearError: true,
        clearSuccess: true,
        clearSplitCheckoutResult: true,
      ),
    );

    try {
      final placed = await apiService.splitPlaceCheckout(
        request: RetailerSplitCheckoutPlaceRequestModel(
          deliveryAddress: deliveryAddress,
          deliveryCountryId: deliveryCountryId,
          deliveryRegionId: deliveryRegionId,
          paymentMethod: paymentMethod,
          notes: notes,
          shippingSelections: _shippingSelectionsFromState(),
        ),
      );

      RetailerSplitCheckoutPlaceModel result = placed;

      if (_isOnlinePaymentMethod(paymentMethod)) {
        result = await apiService.startSplitSessionPayment(
          sessionId: placed.sessionId,
          request: RetailerStartPaymentRequestModel(paymentMethod: paymentMethod),
        );
      }

      final paymentModel = result.toPaymentStartModel();

      emit(
        state.copyWith(
          isPlacingOrder: false,
          splitCheckoutResult: result,
          paymentResult: paymentModel,
          successMessage: _shouldWaitForOnlinePayment(paymentModel)
              ? null
              : _successMessageForSplitPayment(result),
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

  Future<void> confirmStripePayment({required int orderId}) async {
    emit(
      state.copyWith(
        isPlacingOrder: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final payment = await apiService.confirmStripePayment(orderId: orderId);

      emit(
        state.copyWith(
          isPlacingOrder: false,
          paymentResult: payment,
          successMessage: payment.fullyPaid
              ? 'Payment completed. Order sent to supplier.'
              : 'Payment is not completed yet.',
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

  Future<void> confirmMpgsPayment({required int orderId}) async {
    emit(
      state.copyWith(
        isPlacingOrder: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final payment = await apiService.confirmMpgsPayment(orderId: orderId);

      emit(
        state.copyWith(
          isPlacingOrder: false,
          paymentResult: payment,
          successMessage: payment.fullyPaid
              ? 'Payment completed. Order sent to supplier.'
              : 'Payment is not completed yet.',
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

  Future<void> confirmPaypalPayment({required int orderId}) async {
    emit(
      state.copyWith(
        isPlacingOrder: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final payment = await apiService.confirmPaypalPayment(orderId: orderId);

      emit(
        state.copyWith(
          isPlacingOrder: false,
          paymentResult: payment,
          successMessage: payment.fullyPaid
              ? 'Payment completed. Order sent to supplier.'
              : 'Payment is not completed yet.',
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

  Future<void> confirmSplitStripePayment({required int sessionId}) async {
    emit(
      state.copyWith(
        isPlacingOrder: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await apiService.confirmSplitStripePayment(
        sessionId: sessionId,
      );

      emit(
        state.copyWith(
          isPlacingOrder: false,
          splitCheckoutResult: result,
          paymentResult: result.toPaymentStartModel(),
          successMessage: result.fullyPaid
              ? 'Payment completed. Orders sent to supplier.'
              : 'Payment is not completed yet.',
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

  Future<void> confirmSplitMpgsPayment({required int sessionId}) async {
    emit(
      state.copyWith(
        isPlacingOrder: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await apiService.confirmSplitMpgsPayment(
        sessionId: sessionId,
      );

      emit(
        state.copyWith(
          isPlacingOrder: false,
          splitCheckoutResult: result,
          paymentResult: result.toPaymentStartModel(),
          successMessage: result.fullyPaid
              ? 'Payment completed. Orders sent to supplier.'
              : 'Payment is not completed yet.',
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

  List<RetailerSplitCheckoutShippingSelectionRequestModel>
      _shippingSelectionsFromState() {
    return state.selectedSplitShippingMethodIds.entries
        .map(
          (entry) => RetailerSplitCheckoutShippingSelectionRequestModel(
            branchId: entry.key,
            shippingMethodId: entry.value,
          ),
        )
        .toList();
  }

  Map<int, int?> _shippingSelectionsFromPreview(
    RetailerSplitCheckoutPreviewModel preview,
  ) {
    return {
      for (final group in preview.groups)
        group.branchId: group.selectedShippingMethod?.id,
    };
  }

  String? _resolvePaymentMethod({
    required List<RetailerCheckoutPaymentMethodModel> paymentMethods,
    required String? currentSelectedPaymentMethod,
  }) {
    final enabledPaymentMethods = paymentMethods
        .where((method) => method.enabled && !method.comingSoon)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (currentSelectedPaymentMethod != null &&
        enabledPaymentMethods.any(
          (method) => method.methodName == currentSelectedPaymentMethod,
        )) {
      return currentSelectedPaymentMethod;
    }

    if (enabledPaymentMethods.isEmpty) return null;
    return enabledPaymentMethods.first.methodName;
  }

  bool _isOnlinePaymentMethod(String paymentMethod) {
    final method = paymentMethod.toUpperCase();
    return method == 'STRIPE' || method == 'MPGS' || method == 'PAYPAL';
  }

  bool _shouldWaitForOnlinePayment(RetailerCheckoutPaymentStartModel payment) {
    final method = payment.paymentMethod.toUpperCase();
    return method != 'CASH' && payment.onlinePaymentActionRequired;
  }

  String _successMessageForPayment(RetailerCheckoutPaymentStartModel payment) {
    final method = payment.paymentMethod.toUpperCase();

    if (method == 'CASH') {
      return 'Order placed successfully. Cash payment is pending supplier confirmation.';
    }

    if (method == 'STRIPE') {
      return 'Stripe payment is ready. Complete payment to send the order to supplier.';
    }

    if (method == 'MPGS') {
      return 'Card checkout is ready. Complete payment to send the order to supplier.';
    }

    return 'Order created successfully.';
  }

  String _successMessageForSplitPayment(RetailerSplitCheckoutPlaceModel result) {
    final method = result.paymentMethod.toUpperCase();

    if (method == 'CASH') {
      return result.orders.length <= 1
          ? 'Order placed successfully. Cash payment is pending supplier confirmation.'
          : '${result.orders.length} orders placed successfully. Cash payments are pending supplier confirmation.';
    }

    if (method == 'STRIPE') {
      return 'Stripe payment is ready. Complete payment to send the orders to supplier.';
    }

    if (method == 'MPGS') {
      return 'Card checkout is ready. Complete payment to send the orders to supplier.';
    }

    return 'Orders created successfully.';
  }
}
