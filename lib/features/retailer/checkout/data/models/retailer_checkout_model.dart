import '../../../../../core/currency/app_currency_runtime_store.dart';

class RetailerEligibleCheckoutBranchModel {
  final int id;
  final String name;
  final String? city;
  final String? address;

  const RetailerEligibleCheckoutBranchModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
  });

  factory RetailerEligibleCheckoutBranchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RetailerEligibleCheckoutBranchModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString(),
      address: json['address']?.toString(),
    );
  }

  String get displayLabel {
    final details = <String>[];

    if (city != null && city!.trim().isNotEmpty) {
      details.add(city!.trim());
    }

    if (address != null && address!.trim().isNotEmpty) {
      details.add(address!.trim());
    }

    if (details.isEmpty) return name;
    return '$name - ${details.join(', ')}';
  }
}

class RetailerCheckoutPreviewRequestModel {
  final int branchId;
  final int countryId;
  final int? regionId;
  final int? selectedShippingMethodId;

  const RetailerCheckoutPreviewRequestModel({
    required this.branchId,
    required this.countryId,
    required this.regionId,
    required this.selectedShippingMethodId,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'countryId': countryId,
      'regionId': regionId,
      'selectedShippingMethodId': selectedShippingMethodId,
    };
  }
}

class RetailerCreateCheckoutOrderRequestModel {
  final int branchId;
  final String deliveryAddress;
  final int deliveryCountryId;
  final int? deliveryRegionId;
  final int? shippingMethodId;
  final String paymentMethod;
  final String? notes;

  const RetailerCreateCheckoutOrderRequestModel({
    required this.branchId,
    required this.deliveryAddress,
    required this.deliveryCountryId,
    required this.deliveryRegionId,
    required this.shippingMethodId,
    required this.paymentMethod,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'deliveryAddress': deliveryAddress,
      'deliveryCountryId': deliveryCountryId,
      'deliveryRegionId': deliveryRegionId,
      'shippingMethodId': shippingMethodId,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }
}

class RetailerStartPaymentRequestModel {
  final String paymentMethod;
  final String currency;

  RetailerStartPaymentRequestModel({
    required this.paymentMethod,
    String? currency,
  }) : currency = currency ?? AppCurrencyRuntimeStore.code;

  Map<String, dynamic> toJson() {
    return {'paymentMethod': paymentMethod, 'currency': currency};
  }
}

class RetailerCheckoutPreviewModel {
  final int branchId;
  final String branchName;
  final int countryId;
  final String countryName;
  final int? regionId;
  final String? regionName;
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
  final List<RetailerCheckoutPaymentMethodModel> paymentMethods;

  const RetailerCheckoutPreviewModel({
    required this.branchId,
    required this.branchName,
    required this.countryId,
    required this.countryName,
    required this.regionId,
    required this.regionName,
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
    required this.paymentMethods,
  });

  factory RetailerCheckoutPreviewModel.fromJson(Map<String, dynamic> json) {
    return RetailerCheckoutPreviewModel(
      branchId: _toInt(json['branchId']),
      branchName: json['branchName']?.toString() ?? '',
      countryId: _toInt(json['countryId']),
      countryName: json['countryName']?.toString() ?? '',
      regionId: _toNullableInt(json['regionId']),
      regionName: json['regionName']?.toString(),
      items: _asList(
        json['items'],
      ).map(RetailerCheckoutItemModel.fromJson).toList(),
      totalItems: _toInt(json['totalItems']),
      itemsSubtotal: _toDouble(json['itemsSubtotal']),
      discountedItemsSubtotal: _toDouble(json['discountedItemsSubtotal']),
      promotionDiscount: _toDouble(json['promotionDiscount']),
      availableShippingMethods: _asList(
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
      paymentMethods: _asList(
        json['paymentMethods'],
      ).map(RetailerCheckoutPaymentMethodModel.fromJson).toList(),
    );
  }

  String get currency {
    if (items.isEmpty) return AppCurrencyRuntimeStore.symbol;
    return items.first.currency;
  }
}

class RetailerCheckoutItemModel {
  final int cartItemId;
  final int productId;
  final int? supplierBuild4allUserId;
  final String productName;
  final String? imageUrl;
  final String currency;
  final int quantity;
  final int moq;
  final String moqUnit;
  final double originalUnitPrice;
  final double unitPrice;
  final double originalLineTotal;
  final double lineTotal;
  final double promotionDiscount;
  final bool hasActivePromotion;
  final int? promotionId;
  final String? promotionTitle;
  final String? promotionTargetType;
  final String? promotionDiscountType;
  final double promotionDiscountValue;
  final String? promotionLabel;
  final int? discountPercent;

  const RetailerCheckoutItemModel({
    required this.cartItemId,
    required this.productId,
    required this.supplierBuild4allUserId,
    required this.productName,
    required this.imageUrl,
    required this.currency,
    required this.quantity,
    required this.moq,
    required this.moqUnit,
    required this.originalUnitPrice,
    required this.unitPrice,
    required this.originalLineTotal,
    required this.lineTotal,
    required this.promotionDiscount,
    required this.hasActivePromotion,
    required this.promotionId,
    required this.promotionTitle,
    required this.promotionTargetType,
    required this.promotionDiscountType,
    required this.promotionDiscountValue,
    required this.promotionLabel,
    required this.discountPercent,
  });

  factory RetailerCheckoutItemModel.fromJson(Map<String, dynamic> json) {
    return RetailerCheckoutItemModel(
      cartItemId: _toInt(json['cartItemId']),
      productId: _toInt(json['productId']),
      supplierBuild4allUserId: _toNullableInt(json['supplierBuild4allUserId']),
      productName: json['productName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      currency: json['currency']?.toString() ?? AppCurrencyRuntimeStore.symbol,
      quantity: _toInt(json['quantity'], fallback: 1),
      moq: _toInt(json['moq'], fallback: 1),
      moqUnit: json['moqUnit']?.toString() ?? 'units',
      originalUnitPrice: _toDouble(json['originalUnitPrice']),
      unitPrice: _toDouble(json['unitPrice']),
      originalLineTotal: _toDouble(json['originalLineTotal']),
      lineTotal: _toDouble(json['lineTotal']),
      promotionDiscount: _toDouble(json['promotionDiscount']),
      hasActivePromotion: json['hasActivePromotion'] == true,
      promotionId: _toNullableInt(json['promotionId']),
      promotionTitle: json['promotionTitle']?.toString(),
      promotionTargetType: json['promotionTargetType']?.toString(),
      promotionDiscountType: json['promotionDiscountType']?.toString(),
      promotionDiscountValue: _toDouble(json['promotionDiscountValue']),
      promotionLabel: json['promotionLabel']?.toString(),
      discountPercent: _toNullableInt(json['discountPercent']),
    );
  }

  bool get shouldShowOriginalPrice {
    return hasActivePromotion && originalUnitPrice > unitPrice;
  }
}

class RetailerCheckoutShippingMethodModel {
  final int id;
  final String methodName;
  final String methodType;
  final int? countryId;
  final String? countryName;
  final int? regionId;
  final String? regionName;
  final double shippingCost;
  final double appliedShippingCost;
  final double minimumOrderAmount;
  final double freeShippingThreshold;
  final String? estimatedDeliveryTime;
  final bool appliesToAllBranches;
  final bool freeShippingApplied;
  final String? notes;

  const RetailerCheckoutShippingMethodModel({
    required this.id,
    required this.methodName,
    required this.methodType,
    required this.countryId,
    required this.countryName,
    required this.regionId,
    required this.regionName,
    required this.shippingCost,
    required this.appliedShippingCost,
    required this.minimumOrderAmount,
    required this.freeShippingThreshold,
    required this.estimatedDeliveryTime,
    required this.appliesToAllBranches,
    required this.freeShippingApplied,
    required this.notes,
  });

  factory RetailerCheckoutShippingMethodModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RetailerCheckoutShippingMethodModel(
      id: _toInt(json['id']),
      methodName: json['methodName']?.toString() ?? '',
      methodType: json['methodType']?.toString() ?? '',
      countryId: _toNullableInt(json['countryId']),
      countryName: json['countryName']?.toString(),
      regionId: _toNullableInt(json['regionId']),
      regionName: json['regionName']?.toString(),
      shippingCost: _toDouble(json['shippingCost']),
      appliedShippingCost: _toDouble(json['appliedShippingCost']),
      minimumOrderAmount: _toDouble(json['minimumOrderAmount']),
      freeShippingThreshold: _toDouble(json['freeShippingThreshold']),
      estimatedDeliveryTime: json['estimatedDeliveryTime']?.toString(),
      appliesToAllBranches: json['appliesToAllBranches'] == true,
      freeShippingApplied: json['freeShippingApplied'] == true,
      notes: json['notes']?.toString(),
    );
  }

  bool get isPickup {
    final normalizedType = methodType.toUpperCase();
    return normalizedType == 'PICKUP' || normalizedType == 'PICKUP_FROM_BRANCH';
  }
}

class RetailerCheckoutTaxPreviewModel {
  final bool taxApplied;
  final int? taxRuleId;
  final String? taxRuleName;
  final double taxRate;
  final double itemsSubtotal;
  final double promotionDiscount;
  final double taxableItemsAmount;
  final double shippingCost;
  final bool appliesToShipping;
  final double taxableAmount;
  final double itemsTax;
  final double shippingTax;
  final double totalTax;

  const RetailerCheckoutTaxPreviewModel({
    required this.taxApplied,
    required this.taxRuleId,
    required this.taxRuleName,
    required this.taxRate,
    required this.itemsSubtotal,
    required this.promotionDiscount,
    required this.taxableItemsAmount,
    required this.shippingCost,
    required this.appliesToShipping,
    required this.taxableAmount,
    required this.itemsTax,
    required this.shippingTax,
    required this.totalTax,
  });

  factory RetailerCheckoutTaxPreviewModel.fromJson(Map<String, dynamic> json) {
    return RetailerCheckoutTaxPreviewModel(
      taxApplied: json['taxApplied'] == true,
      taxRuleId: _toNullableInt(json['taxRuleId']),
      taxRuleName: json['taxRuleName']?.toString(),
      taxRate: _toDouble(json['taxRate']),
      itemsSubtotal: _toDouble(json['itemsSubtotal']),
      promotionDiscount: _toDouble(json['promotionDiscount']),
      taxableItemsAmount: _toDouble(json['taxableItemsAmount']),
      shippingCost: _toDouble(json['shippingCost']),
      appliesToShipping: json['appliesToShipping'] == true,
      taxableAmount: _toDouble(json['taxableAmount']),
      itemsTax: _toDouble(json['itemsTax']),
      shippingTax: _toDouble(json['shippingTax']),
      totalTax: _toDouble(json['totalTax']),
    );
  }
}

class RetailerCheckoutPaymentMethodModel {
  final String methodName;
  final String displayName;
  final String description;
  final bool enabled;
  final bool onlinePaymentActionRequired;
  final bool comingSoon;
  final int sortOrder;

  const RetailerCheckoutPaymentMethodModel({
    required this.methodName,
    required this.displayName,
    required this.description,
    required this.enabled,
    required this.onlinePaymentActionRequired,
    required this.comingSoon,
    required this.sortOrder,
  });

  factory RetailerCheckoutPaymentMethodModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RetailerCheckoutPaymentMethodModel(
      methodName: json['methodName']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      enabled: json['enabled'] == true,
      onlinePaymentActionRequired: json['onlinePaymentActionRequired'] == true,
      comingSoon: json['comingSoon'] == true,
      sortOrder: _toInt(json['sortOrder']),
    );
  }
}

class RetailerCheckoutOrderModel {
  final int id;
  final String orderNumber;
  final String paymentMethod;
  final double totalAmount;

  const RetailerCheckoutOrderModel({
    required this.id,
    required this.orderNumber,
    required this.paymentMethod,
    required this.totalAmount,
  });

  factory RetailerCheckoutOrderModel.fromJson(Map<String, dynamic> json) {
    return RetailerCheckoutOrderModel(
      id: _toInt(json['id'] ?? json['orderId']),
      orderNumber: json['orderNumber']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      totalAmount: _toDouble(json['totalAmount']),
    );
  }
}

class RetailerCheckoutPaymentStartModel {
  final int? orderId;
  final String? orderNumber;
  final String paymentMethod;
  final String paymentState;
  final String latestPaymentStatus;
  final double orderTotal;
  final double paidAmount;
  final double remainingAmount;
  final bool fullyPaid;
  final String? providerCode;
  final String? providerPaymentId;
  final String? clientSecret;
  final String? publishableKey;
  final String? redirectUrl;
  final String? mpgsSessionId;
  final String? mpgsSuccessIndicator;
  final bool onlinePaymentActionRequired;

  const RetailerCheckoutPaymentStartModel({
    required this.orderId,
    required this.orderNumber,
    required this.paymentMethod,
    required this.paymentState,
    required this.latestPaymentStatus,
    required this.orderTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.fullyPaid,
    required this.providerCode,
    required this.providerPaymentId,
    required this.clientSecret,
    required this.publishableKey,
    required this.redirectUrl,
    required this.mpgsSessionId,
    required this.mpgsSuccessIndicator,
    required this.onlinePaymentActionRequired,
  });

  factory RetailerCheckoutPaymentStartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RetailerCheckoutPaymentStartModel(
      orderId: _toNullableInt(json['orderId']),
      orderNumber: json['orderNumber']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentState: json['paymentState']?.toString() ?? '',
      latestPaymentStatus: json['latestPaymentStatus']?.toString() ?? '',
      orderTotal: _toDouble(json['orderTotal']),
      paidAmount: _toDouble(json['paidAmount']),
      remainingAmount: _toDouble(json['remainingAmount']),
      fullyPaid: json['fullyPaid'] == true,
      providerCode: json['providerCode']?.toString(),
      providerPaymentId: json['providerPaymentId']?.toString(),
      clientSecret: json['clientSecret']?.toString(),
      publishableKey: json['publishableKey']?.toString(),
      redirectUrl: json['redirectUrl']?.toString(),
      mpgsSessionId: json['mpgsSessionId']?.toString(),
      mpgsSuccessIndicator: json['mpgsSuccessIndicator']?.toString(),
      onlinePaymentActionRequired: json['onlinePaymentActionRequired'] == true,
    );
  }
}

List<Map<String, dynamic>> _asList(dynamic value) {
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

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}
