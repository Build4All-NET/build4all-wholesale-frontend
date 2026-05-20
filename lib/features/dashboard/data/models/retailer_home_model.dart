class RetailerHomeModel {
  final String welcomeName;
  final int unreadNotificationsCount;
  final int cartItemsCount;
  final List<HomeBannerModel> banners;
  final GroupDeliveryModel? groupDelivery;
  final List<QuickActionModel> quickActions;
  final List<HomeCategoryModel> categories;
  final List<HomeProductModel> featuredProducts;

  const RetailerHomeModel({
    required this.welcomeName,
    required this.unreadNotificationsCount,
    required this.cartItemsCount,
    required this.banners,
    required this.groupDelivery,
    required this.quickActions,
    required this.categories,
    required this.featuredProducts,
  });

  factory RetailerHomeModel.fromJson(Map<String, dynamic> json) {
    return RetailerHomeModel(
      welcomeName: json['welcomeName']?.toString() ?? '',
      unreadNotificationsCount: _toInt(json['unreadNotificationsCount']),
      cartItemsCount: _toInt(json['cartItemsCount']),
      banners: (json['banners'] as List<dynamic>? ?? [])
          .map(
            (item) => HomeBannerModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      groupDelivery: json['groupDelivery'] == null
          ? null
          : GroupDeliveryModel.fromJson(
              Map<String, dynamic>.from(json['groupDelivery'] as Map),
            ),
      quickActions: (json['quickActions'] as List<dynamic>? ?? [])
          .map(
            (item) => QuickActionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map(
            (item) => HomeCategoryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      featuredProducts: (json['featuredProducts'] as List<dynamic>? ?? [])
          .map(
            (item) => HomeProductModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  RetailerHomeModel copyWith({
    String? welcomeName,
    int? unreadNotificationsCount,
    int? cartItemsCount,
    List<HomeBannerModel>? banners,
    GroupDeliveryModel? groupDelivery,
    List<QuickActionModel>? quickActions,
    List<HomeCategoryModel>? categories,
    List<HomeProductModel>? featuredProducts,
  }) {
    return RetailerHomeModel(
      welcomeName: welcomeName ?? this.welcomeName,
      unreadNotificationsCount:
          unreadNotificationsCount ?? this.unreadNotificationsCount,
      cartItemsCount: cartItemsCount ?? this.cartItemsCount,
      banners: banners ?? this.banners,
      groupDelivery: groupDelivery ?? this.groupDelivery,
      quickActions: quickActions ?? this.quickActions,
      categories: categories ?? this.categories,
      featuredProducts: featuredProducts ?? this.featuredProducts,
    );
  }
}

class HomeBannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String ctaLabel;
  final String bannerType;
  final String? backgroundColorStart;
  final String? backgroundColorEnd;
  final String targetType;
  final String? targetValue;

  const HomeBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaLabel,
    required this.bannerType,
    required this.backgroundColorStart,
    required this.backgroundColorEnd,
    required this.targetType,
    required this.targetValue,
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      ctaLabel: json['ctaLabel']?.toString() ?? '',
      bannerType: json['bannerType']?.toString() ?? '',
      backgroundColorStart: json['backgroundColorStart']?.toString(),
      backgroundColorEnd: json['backgroundColorEnd']?.toString(),
      targetType: json['targetType']?.toString() ?? 'NONE',
      targetValue: json['targetValue']?.toString(),
    );
  }
}

class GroupDeliveryModel {
  final bool available;
  final String title;
  final String description;
  final String ctaLabel;

  const GroupDeliveryModel({
    required this.available,
    required this.title,
    required this.description,
    required this.ctaLabel,
  });

  factory GroupDeliveryModel.fromJson(Map<String, dynamic> json) {
    return GroupDeliveryModel(
      available: json['available'] == true,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ctaLabel: json['ctaLabel']?.toString() ?? '',
    );
  }
}

class QuickActionModel {
  final String label;
  final String icon;
  final String route;
  final String colorHex;

  const QuickActionModel({
    required this.label,
    required this.icon,
    required this.route,
    required this.colorHex,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      label: json['label']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      colorHex: json['colorHex']?.toString() ?? '',
    );
  }
}

class HomeCategoryModel {
  final int id;
  final String name;
  final String icon;
  final int productCount;

  /// Promotion fields are optional because old backend responses may not
  /// include them yet. When the backend later marks a category promotion as
  /// active, the existing category UI can show a small deals indicator without
  /// changing the category structure.
  final bool hasActivePromotion;
  final int? promotionId;
  final String? promotionTitle;
  final String? promotionDiscountType;
  final double? promotionDiscountValue;
  final String? promotionLabel;

  const HomeCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.productCount,
    required this.hasActivePromotion,
    required this.promotionId,
    required this.promotionTitle,
    required this.promotionDiscountType,
    required this.promotionDiscountValue,
    required this.promotionLabel,
  });

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    final discountType = json['promotionDiscountType']?.toString();
    final discountValue = json['promotionDiscountValue'] == null
        ? null
        : _toDouble(json['promotionDiscountValue']);
    final backendLabel = json['promotionLabel']?.toString();

    return HomeCategoryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '📦',
      productCount: _toInt(json['productCount']),
      hasActivePromotion:
          json['hasActivePromotion'] == true ||
          json['activePromotion'] == true ||
          backendLabel != null,
      promotionId: json['promotionId'] == null
          ? null
          : _toInt(json['promotionId']),
      promotionTitle: json['promotionTitle']?.toString(),
      promotionDiscountType: discountType,
      promotionDiscountValue: discountValue,
      promotionLabel:
          _normalizeText(backendLabel) ??
          _buildPromotionLabel(discountType, discountValue),
    );
  }
}

class HomeProductModel {
  final int id;
  final int? supplierBuild4allUserId;

  final int? categoryId;
  final String? categoryName;

  final int? subCategoryId;
  final String? subCategoryName;

  final String name;
  final String description;
  final String? imageUrl;

  final double price;
  final String currency;

  final int moq;
  final String moqUnit;

  final double rating;
  final int reviewCount;
  final String? badgeLabel;
  final String? badgeColor;
  final int? discountPercent;

  /// Active supplier promotion information. These fields are optional so the
  /// retailer UI remains backward-compatible until the backend endpoint is
  /// added. Product and category promotions both arrive here as the same
  /// display contract.
  final bool hasActivePromotion;
  final int? promotionId;
  final String? promotionTitle;
  final String? promotionTargetType;
  final String? promotionDiscountType;
  final double? promotionDiscountValue;
  final String? promotionLabel;

  final int totalStock;

  const HomeProductModel({
    required this.id,
    required this.supplierBuild4allUserId,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.moq,
    required this.moqUnit,
    required this.rating,
    required this.reviewCount,
    required this.badgeLabel,
    required this.badgeColor,
    required this.discountPercent,
    required this.hasActivePromotion,
    required this.promotionId,
    required this.promotionTitle,
    required this.promotionTargetType,
    required this.promotionDiscountType,
    required this.promotionDiscountValue,
    required this.promotionLabel,
    required this.totalStock,
  });

  factory HomeProductModel.fromJson(Map<String, dynamic> json) {
    final discountPercent = json['discountPercent'] == null
        ? null
        : _toInt(json['discountPercent']);
    final discountType = json['promotionDiscountType']?.toString();
    final discountValue = json['promotionDiscountValue'] == null
        ? null
        : _toDouble(json['promotionDiscountValue']);
    final backendLabel = json['promotionLabel']?.toString();
    final computedPromotionLabel =
        _normalizeText(backendLabel) ??
        _buildPromotionLabel(discountType, discountValue) ??
        (discountPercent == null ? null : '$discountPercent% OFF');

    return HomeProductModel(
      id: _toInt(json['id']),
      supplierBuild4allUserId: json['supplierBuild4allUserId'] == null
          ? null
          : _toInt(json['supplierBuild4allUserId']),
      categoryId: json['categoryId'] == null
          ? null
          : _toInt(json['categoryId']),
      categoryName: json['categoryName']?.toString(),
      subCategoryId: json['subCategoryId'] == null
          ? null
          : _toInt(json['subCategoryId']),
      subCategoryName: json['subCategoryName']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString() ?? r'$',
      moq: _toInt(json['moq'], fallback: 1),
      moqUnit: json['moqUnit']?.toString() ?? 'units',
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['reviewCount']),
      badgeLabel: json['badgeLabel']?.toString(),
      badgeColor: json['badgeColor']?.toString(),
      discountPercent: discountPercent,
      hasActivePromotion:
          json['hasActivePromotion'] == true ||
          json['activePromotion'] == true ||
          computedPromotionLabel != null,
      promotionId: json['promotionId'] == null
          ? null
          : _toInt(json['promotionId']),
      promotionTitle: json['promotionTitle']?.toString(),
      promotionTargetType: json['promotionTargetType']?.toString(),
      promotionDiscountType: discountType,
      promotionDiscountValue: discountValue,
      promotionLabel: computedPromotionLabel,
      totalStock: _toInt(json['totalStock']),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

String? _normalizeText(String? value) {
  final clean = value?.trim();
  if (clean == null || clean.isEmpty) return null;
  return clean;
}

String? _buildPromotionLabel(String? discountType, double? discountValue) {
  if (discountType == null || discountValue == null || discountValue <= 0) {
    return null;
  }

  final upperType = discountType.toUpperCase();
  final formattedValue = _formatNumber(discountValue);

  if (upperType == 'PERCENT') {
    return '$formattedValue% OFF';
  }

  if (upperType == 'FIXED') {
    return '\$$formattedValue OFF';
  }

  return null;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2);
}
