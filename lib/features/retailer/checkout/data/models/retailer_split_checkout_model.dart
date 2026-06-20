import '../../../../../core/currency/app_currency_runtime_store.dart';
import 'retailer_checkout_model.dart';

class RetailerSplitCheckoutShippingSelectionRequestModel {
  final int branchId;
  final int? shippingMethodId;

  const RetailerSplitCheckoutShippingSelectionRequestModel({
    required this.branchId,
    required this.shippingMethodId,
  });

  Map<String, dynamic> toJson() {
    // Backend split checkout DTO expects selectedShippingMethodId.
    // Keep the Dart property name short, but send the exact backend field name.
    return {
      'branchId': branchId,
      'selectedShippingMethodId': shippingMethodId,
    };
  }
}

class RetailerSplitCheckoutPreviewRequestModel {
  final int deliveryCountryId;
  final int? deliveryRegionId;
  final List<RetailerSplitCheckoutShippingSelectionRequestModel>
  shippingSelections;

  const RetailerSplitCheckoutPreviewRequestModel({
    required this.deliveryCountryId,
    required this.deliveryRegionId,
    this.shippingSelections = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      // IMPORTANT:
      // Backend split-preview DTO expects countryId / regionId.
      // Do not send deliveryCountryId / deliveryRegionId here.
      'countryId': deliveryCountryId,
      'regionId': deliveryRegionId,
      'shippingSelections': shippingSelections
          .map((selection) => selection.toJson())
          .toList(),
    };
  }
}

class RetailerSplitCheckoutPlaceRequestModel {
  final String deliveryAddress;
  final int deliveryCountryId;
  final int? deliveryRegionId;
  final String paymentMethod;
  final String? notes;
  final List<RetailerSplitCheckoutShippingSelectionRequestModel>
  shippingSelections;

  const RetailerSplitCheckoutPlaceRequestModel({
    required this.deliveryAddress,
    required this.deliveryCountryId,
    required this.deliveryRegionId,
    required this.paymentMethod,
    required this.shippingSelections,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      // Backend split-place DTO expects deliveryCountryId / deliveryRegionId.
      // Keep these names for place order.
      'deliveryAddress': deliveryAddress,
      'deliveryCountryId': deliveryCountryId,
      'deliveryRegionId': deliveryRegionId,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'shippingSelections': shippingSelections
          .map((selection) => selection.toJson())
          .toList(),
    };
  }
}

class RetailerSplitCheckoutPreviewModel {
  final List<RetailerSplitCheckoutGroupModel> groups;
  final int totalItems;
  final double itemsSubtotal;
  final double discountedItemsSubtotal;
  final double promotionDiscount;
  final double shippingCost;
  final double taxAmount;
  final double finalTotal;
  final List<RetailerCheckoutPaymentMethodModel> paymentMethods;

  const RetailerSplitCheckoutPreviewModel({
    required this.groups,
    required this.totalItems,
    required this.itemsSubtotal,
    required this.discountedItemsSubtotal,
    required this.promotionDiscount,
    required this.shippingCost,
    required this.taxAmount,
    required this.finalTotal,
    required this.paymentMethods,
  });

  factory RetailerSplitCheckoutPreviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RetailerSplitCheckoutPreviewModel(
      groups: _asMapList(
        json['groups'],
      ).map(RetailerSplitCheckoutGroupModel.fromJson).toList(),
      totalItems: _toInt(json['totalItems']),
      itemsSubtotal: _toDouble(json['itemsSubtotal']),
      discountedItemsSubtotal: _toDouble(json['discountedItemsSubtotal']),
      promotionDiscount: _toDouble(json['promotionDiscount']),
      shippingCost: _toDouble(json['shippingCost']),
      taxAmount: _toDouble(json['taxAmount']),
      finalTotal: _toDouble(json['finalTotal']),
      paymentMethods: _asMapList(
        json['paymentMethods'],
      ).map(RetailerCheckoutPaymentMethodModel.fromJson).toList(),
    );
  }

  String get currency {
    for (final group in groups) {
      if (group.items.isNotEmpty) return group.items.first.currency;
    }
    return AppCurrencyRuntimeStore.symbol;
  }
}

class RetailerSplitCheckoutGroupModel {
  final int branchId;
  final String branchName;
  final String? branchCity;
  final String? branchAddress;
  final List<RetailerCheckoutItemModel> items;
  final int totalItems;
  final double itemsSubtotal;
  final double discountedItemsSubtotal;
  final double promotionDiscount;
  final List<RetailerCheckoutShippingMethodModel> availableShippingMethods;
  final RetailerCheckoutShippingMethodModel? selectedShippingMethod;
  final double shippingCost;
  final RetailerCheckoutTaxPreviewModel? taxPreview;
  final double taxAmount;
  final double finalTotal;

  const RetailerSplitCheckoutGroupModel({
    required this.branchId,
    required this.branchName,
    required this.branchCity,
    required this.branchAddress,
    required this.items,
    required this.totalItems,
    required this.itemsSubtotal,
    required this.discountedItemsSubtotal,
    required this.promotionDiscount,
    required this.availableShippingMethods,
    required this.selectedShippingMethod,
    required this.shippingCost,
    required this.taxPreview,
    required this.taxAmount,
    required this.finalTotal,
  });

  factory RetailerSplitCheckoutGroupModel.fromJson(Map<String, dynamic> json) {
    return RetailerSplitCheckoutGroupModel(
      branchId: _toInt(json['branchId']),
      branchName: json['branchName']?.toString() ?? '',
      branchCity: json['branchCity']?.toString(),
      branchAddress: json['branchAddress']?.toString(),
      items: _asMapList(
        json['items'],
      ).map(RetailerCheckoutItemModel.fromJson).toList(),
      totalItems: _toInt(json['totalItems']),
      itemsSubtotal: _toDouble(json['itemsSubtotal']),
      discountedItemsSubtotal: _toDouble(json['discountedItemsSubtotal']),
      promotionDiscount: _toDouble(json['promotionDiscount']),
      availableShippingMethods: _asMapList(
        json['availableShippingMethods'],
      ).map(RetailerCheckoutShippingMethodModel.fromJson).toList(),
      selectedShippingMethod: json['selectedShippingMethod'] is Map
          ? RetailerCheckoutShippingMethodModel.fromJson(
              Map<String, dynamic>.from(json['selectedShippingMethod'] as Map),
            )
          : null,
      shippingCost: _toDouble(json['shippingCost']),
      taxPreview: json['taxPreview'] is Map
          ? RetailerCheckoutTaxPreviewModel.fromJson(
              Map<String, dynamic>.from(json['taxPreview'] as Map),
            )
          : null,
      taxAmount: _toDouble(json['taxAmount']),
      finalTotal: _toDouble(json['finalTotal']),
    );
  }

  String get displayBranchLabel {
    final details = <String>[];

    if (branchCity != null && branchCity!.trim().isNotEmpty) {
      details.add(branchCity!.trim());
    }

    if (branchAddress != null && branchAddress!.trim().isNotEmpty) {
      details.add(branchAddress!.trim());
    }

    if (details.isEmpty) return branchName;

    return '$branchName - ${details.join(', ')}';
  }
}

class RetailerSplitCheckoutPlaceModel {
  final int sessionId;
  final String sessionNumber;
  final String paymentMethod;
  final String paymentState;
  final String latestPaymentStatus;
  final double grandTotal;
  final double paidAmount;
  final double remainingAmount;
  final bool fullyPaid;
  final bool onlinePaymentActionRequired;
  final String? providerCode;
  final String? providerPaymentId;
  final String? clientSecret;
  final String? publishableKey;
  final String? redirectUrl;
  final String? mpgsSessionId;
  final String? mpgsSuccessIndicator;
  final List<RetailerSplitCheckoutPlacedOrderModel> orders;

  const RetailerSplitCheckoutPlaceModel({
    required this.sessionId,
    required this.sessionNumber,
    required this.paymentMethod,
    required this.paymentState,
    required this.latestPaymentStatus,
    required this.grandTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.fullyPaid,
    required this.onlinePaymentActionRequired,
    required this.providerCode,
    required this.providerPaymentId,
    required this.clientSecret,
    required this.publishableKey,
    required this.redirectUrl,
    required this.mpgsSessionId,
    required this.mpgsSuccessIndicator,
    required this.orders,
  });

  factory RetailerSplitCheckoutPlaceModel.fromJson(Map<String, dynamic> json) {
    return RetailerSplitCheckoutPlaceModel(
      sessionId: _toInt(json['sessionId'] ?? json['id']),
      sessionNumber: json['sessionNumber']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentState: json['paymentState']?.toString() ?? '',
      latestPaymentStatus: json['latestPaymentStatus']?.toString() ?? '',
      grandTotal: _toDouble(json['grandTotal'] ?? json['orderTotal']),
      paidAmount: _toDouble(json['paidAmount']),
      remainingAmount: _toDouble(json['remainingAmount']),
      fullyPaid: json['fullyPaid'] == true,
      onlinePaymentActionRequired: json['onlinePaymentActionRequired'] == true,
      providerCode: json['providerCode']?.toString(),
      providerPaymentId: json['providerPaymentId']?.toString(),
      clientSecret: json['clientSecret']?.toString(),
      publishableKey: json['publishableKey']?.toString(),
      redirectUrl: json['redirectUrl']?.toString(),
      mpgsSessionId: json['mpgsSessionId']?.toString(),
      mpgsSuccessIndicator: json['mpgsSuccessIndicator']?.toString(),
      orders: _asMapList(
        json['orders'],
      ).map(RetailerSplitCheckoutPlacedOrderModel.fromJson).toList(),
    );
  }

  RetailerCheckoutPaymentStartModel toPaymentStartModel() {
    return RetailerCheckoutPaymentStartModel(
      orderId: sessionId,
      orderNumber: sessionNumber,
      paymentMethod: paymentMethod,
      paymentState: paymentState,
      latestPaymentStatus: latestPaymentStatus,
      orderTotal: grandTotal,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      fullyPaid: fullyPaid,
      providerCode: providerCode,
      providerPaymentId: providerPaymentId,
      clientSecret: clientSecret,
      publishableKey: publishableKey,
      redirectUrl: redirectUrl,
      mpgsSessionId: mpgsSessionId,
      mpgsSuccessIndicator: mpgsSuccessIndicator,
      onlinePaymentActionRequired: onlinePaymentActionRequired,
    );
  }
}

class RetailerSplitCheckoutPlacedOrderModel {
  final int orderId;
  final String orderNumber;
  final int branchId;
  final String branchName;
  final double orderTotal;

  const RetailerSplitCheckoutPlacedOrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.branchId,
    required this.branchName,
    required this.orderTotal,
  });

  factory RetailerSplitCheckoutPlacedOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RetailerSplitCheckoutPlacedOrderModel(
      orderId: _toInt(json['orderId'] ?? json['id']),
      orderNumber: json['orderNumber']?.toString() ?? '',
      branchId: _toInt(json['branchId']),
      branchName: json['branchName']?.toString() ?? '',
      orderTotal: _toDouble(json['orderTotal'] ?? json['totalAmount']),
    );
  }
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return [];

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value.toString()) ?? fallback;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();

  return double.tryParse(value.toString()) ?? fallback;
}
