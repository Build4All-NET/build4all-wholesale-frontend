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
      welcomeName: json['welcomeName']?.toString() ?? 'Retail Store',
      unreadNotificationsCount: _toInt(json['unreadNotificationsCount']),
      cartItemsCount: _toInt(json['cartItemsCount']),
      banners: (json['banners'] as List? ?? [])
          .map(
            (item) => HomeBannerModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      groupDelivery: json['groupDelivery'] == null
          ? null
          : GroupDeliveryModel.fromJson(
              Map<String, dynamic>.from(json['groupDelivery'] as Map),
            ),
      quickActions: (json['quickActions'] as List? ?? [])
          .map(
            (item) =>
                QuickActionModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      categories: (json['categories'] as List? ?? [])
          .map(
            (item) =>
                HomeCategoryModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      featuredProducts: (json['featuredProducts'] as List? ?? [])
          .map(
            (item) =>
                HomeProductModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
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
  final String backgroundColorStart;
  final String backgroundColorEnd;

  const HomeBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaLabel,
    required this.bannerType,
    required this.backgroundColorStart,
    required this.backgroundColorEnd,
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      ctaLabel: json['ctaLabel']?.toString() ?? 'Shop Now',
      bannerType: json['bannerType']?.toString() ?? '',
      backgroundColorStart:
          json['backgroundColorStart']?.toString() ?? '#16A34A',
      backgroundColorEnd: json['backgroundColorEnd']?.toString() ?? '#15803D',
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
      ctaLabel: json['ctaLabel']?.toString() ?? 'Learn More',
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
      colorHex: json['colorHex']?.toString() ?? '#16A34A',
    );
  }
}

class HomeCategoryModel {
  final int id;
  final String name;
  final String icon;
  final int productCount;

  const HomeCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.productCount,
  });

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return HomeCategoryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '📦',
      productCount: _toInt(json['productCount']),
    );
  }
}

class HomeProductModel {
  final int id;
  final int? supplierBuild4allUserId;
  final int? categoryId;
  final String name;
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

  const HomeProductModel({
    required this.id,
    required this.supplierBuild4allUserId,
    required this.categoryId,
    required this.name,
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
  });

  factory HomeProductModel.fromJson(Map<String, dynamic> json) {
    return HomeProductModel(
      id: _toInt(json['id']),
      supplierBuild4allUserId: json['supplierBuild4allUserId'] == null
          ? null
          : _toInt(json['supplierBuild4allUserId']),
      categoryId: json['categoryId'] == null
          ? null
          : _toInt(json['categoryId']),
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString() ?? '\$',
      moq: _toInt(json['moq'], fallback: 1),
      moqUnit: json['moqUnit']?.toString() ?? 'units',
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['reviewCount']),
      badgeLabel: json['badgeLabel']?.toString(),
      badgeColor: json['badgeColor']?.toString(),
      discountPercent: json['discountPercent'] == null
          ? null
          : _toInt(json['discountPercent']),
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
