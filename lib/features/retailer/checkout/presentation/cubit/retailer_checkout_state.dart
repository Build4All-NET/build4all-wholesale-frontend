import 'package:equatable/equatable.dart';

import '../../data/models/retailer_checkout_model.dart';
import '../../data/models/retailer_split_checkout_model.dart';

class RetailerCheckoutState extends Equatable {
  final bool isLoadingBranches;
  final bool isLoadingPreview;
  final bool isPlacingOrder;
  final bool isLoadingSplitPreview;
  final List<RetailerEligibleCheckoutBranchModel> eligibleBranches;
  final RetailerEligibleCheckoutBranchModel? selectedBranch;
  final RetailerCheckoutPreviewModel? preview;
  final RetailerSplitCheckoutPreviewModel? splitPreview;
  final RetailerCheckoutOrderModel? createdOrder;
  final RetailerCheckoutPaymentStartModel? paymentResult;
  final RetailerSplitCheckoutPlaceModel? splitCheckoutResult;
  final Map<int, int?> selectedSplitShippingMethodIds;
  final int? selectedShippingMethodId;
  final String? selectedPaymentMethod;
  final String? errorMessage;
  final String? successMessage;

  const RetailerCheckoutState({
    this.isLoadingBranches = false,
    this.isLoadingPreview = false,
    this.isPlacingOrder = false,
    this.isLoadingSplitPreview = false,
    this.eligibleBranches = const [],
    this.selectedBranch,
    this.preview,
    this.splitPreview,
    this.createdOrder,
    this.paymentResult,
    this.splitCheckoutResult,
    this.selectedSplitShippingMethodIds = const {},
    this.selectedShippingMethodId,
    this.selectedPaymentMethod,
    this.errorMessage,
    this.successMessage,
  });

  RetailerCheckoutState copyWith({
    bool? isLoadingBranches,
    bool? isLoadingPreview,
    bool? isPlacingOrder,
    bool? isLoadingSplitPreview,
    List<RetailerEligibleCheckoutBranchModel>? eligibleBranches,
    RetailerEligibleCheckoutBranchModel? selectedBranch,
    bool clearSelectedBranch = false,
    RetailerCheckoutPreviewModel? preview,
    bool clearPreview = false,
    RetailerSplitCheckoutPreviewModel? splitPreview,
    bool clearSplitPreview = false,
    RetailerCheckoutOrderModel? createdOrder,
    RetailerCheckoutPaymentStartModel? paymentResult,
    RetailerSplitCheckoutPlaceModel? splitCheckoutResult,
    bool clearSplitCheckoutResult = false,
    Map<int, int?>? selectedSplitShippingMethodIds,
    int? selectedShippingMethodId,
    bool clearSelectedShippingMethodId = false,
    String? selectedPaymentMethod,
    bool clearSelectedPaymentMethod = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return RetailerCheckoutState(
      isLoadingBranches: isLoadingBranches ?? this.isLoadingBranches,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      isLoadingSplitPreview:
          isLoadingSplitPreview ?? this.isLoadingSplitPreview,
      eligibleBranches: eligibleBranches ?? this.eligibleBranches,
      selectedBranch: clearSelectedBranch
          ? null
          : selectedBranch ?? this.selectedBranch,
      preview: clearPreview ? null : preview ?? this.preview,
      splitPreview: clearSplitPreview ? null : splitPreview ?? this.splitPreview,
      createdOrder: createdOrder ?? this.createdOrder,
      paymentResult: paymentResult ?? this.paymentResult,
      splitCheckoutResult: clearSplitCheckoutResult
          ? null
          : splitCheckoutResult ?? this.splitCheckoutResult,
      selectedSplitShippingMethodIds: selectedSplitShippingMethodIds ??
          this.selectedSplitShippingMethodIds,
      selectedShippingMethodId: clearSelectedShippingMethodId
          ? null
          : selectedShippingMethodId ?? this.selectedShippingMethodId,
      selectedPaymentMethod: clearSelectedPaymentMethod
          ? null
          : selectedPaymentMethod ?? this.selectedPaymentMethod,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  bool get hasSplitCheckout => splitPreview != null;

  bool get hasMissingSplitShippingMethod {
    final currentPreview = splitPreview;
    if (currentPreview == null) return false;

    return currentPreview.groups.any(
      (group) => group.selectedShippingMethod == null,
    );
  }

  @override
  List<Object?> get props => [
        isLoadingBranches,
        isLoadingPreview,
        isPlacingOrder,
        isLoadingSplitPreview,
        eligibleBranches,
        selectedBranch,
        preview,
        splitPreview,
        createdOrder,
        paymentResult,
        splitCheckoutResult,
        selectedSplitShippingMethodIds,
        selectedShippingMethodId,
        selectedPaymentMethod,
        errorMessage,
        successMessage,
      ];
}
