import 'package:equatable/equatable.dart';

import '../../data/models/retailer_checkout_model.dart';

class RetailerCheckoutState extends Equatable {
  final bool isLoadingBranches;
  final bool isLoadingPreview;
  final bool isPlacingOrder;
  final List<RetailerEligibleCheckoutBranchModel> eligibleBranches;
  final RetailerEligibleCheckoutBranchModel? selectedBranch;
  final RetailerCheckoutPreviewModel? preview;
  final RetailerCheckoutOrderModel? createdOrder;
  final RetailerCheckoutPaymentStartModel? paymentResult;
  final int? selectedShippingMethodId;
  final String? selectedPaymentMethod;
  final String? errorMessage;
  final String? successMessage;

  const RetailerCheckoutState({
    this.isLoadingBranches = false,
    this.isLoadingPreview = false,
    this.isPlacingOrder = false,
    this.eligibleBranches = const [],
    this.selectedBranch,
    this.preview,
    this.createdOrder,
    this.paymentResult,
    this.selectedShippingMethodId,
    this.selectedPaymentMethod,
    this.errorMessage,
    this.successMessage,
  });

  RetailerCheckoutState copyWith({
    bool? isLoadingBranches,
    bool? isLoadingPreview,
    bool? isPlacingOrder,
    List<RetailerEligibleCheckoutBranchModel>? eligibleBranches,
    RetailerEligibleCheckoutBranchModel? selectedBranch,
    bool clearSelectedBranch = false,
    RetailerCheckoutPreviewModel? preview,
    bool clearPreview = false,
    RetailerCheckoutOrderModel? createdOrder,
    RetailerCheckoutPaymentStartModel? paymentResult,
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
      eligibleBranches: eligibleBranches ?? this.eligibleBranches,
      selectedBranch: clearSelectedBranch
          ? null
          : selectedBranch ?? this.selectedBranch,
      preview: clearPreview ? null : preview ?? this.preview,
      createdOrder: createdOrder ?? this.createdOrder,
      paymentResult: paymentResult ?? this.paymentResult,
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

  @override
  List<Object?> get props => [
    isLoadingBranches,
    isLoadingPreview,
    isPlacingOrder,
    eligibleBranches,
    selectedBranch,
    preview,
    createdOrder,
    paymentResult,
    selectedShippingMethodId,
    selectedPaymentMethod,
    errorMessage,
    successMessage,
  ];
}
