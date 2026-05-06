import 'package:equatable/equatable.dart';

enum BannerTargetType {
  none,
  product,
  category,
  subcategory,
  url,
}

extension BannerTargetTypeX on BannerTargetType {
  String get label {
    switch (this) {
      case BannerTargetType.none:
        return 'None';
      case BannerTargetType.product:
        return 'Product';
      case BannerTargetType.category:
        return 'Category';
      case BannerTargetType.subcategory:
        return 'Subcategory';
      case BannerTargetType.url:
        return 'URL';
    }
  }

  String get backendValue {
    switch (this) {
      case BannerTargetType.none:
        return 'NONE';
      case BannerTargetType.product:
        return 'PRODUCT';
      case BannerTargetType.category:
        return 'CATEGORY';
      case BannerTargetType.subcategory:
        return 'SUBCATEGORY';
      case BannerTargetType.url:
        return 'URL';
    }
  }

  static BannerTargetType fromBackend(String? value) {
    switch (value?.toUpperCase()) {
      case 'PRODUCT':
        return BannerTargetType.product;
      case 'CATEGORY':
        return BannerTargetType.category;
      case 'SUBCATEGORY':
        return BannerTargetType.subcategory;
      case 'URL':
        return BannerTargetType.url;
      case 'NONE':
      default:
        return BannerTargetType.none;
    }
  }
}

class BannerEntity extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final BannerTargetType targetType;
  final String? targetValue;
  final String? targetLabel;
  final int sortOrder;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BannerEntity({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.targetType,
    this.targetValue,
    this.targetLabel,
    required this.sortOrder,
    this.startsAt,
    this.expiresAt,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  bool get started {
    if (startsAt == null) return true;
    return !DateTime.now().isBefore(startsAt!);
  }

  bool get expired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get currentlyValid {
    return active && started && !expired;
  }

  bool get currentlyVisible => currentlyValid;

  String get status {
    if (!active) return 'INACTIVE';
    if (!started) return 'SCHEDULED';
    if (expired) return 'EXPIRED';

    return 'ACTIVE';
  }

  String get statusLabel {
    switch (status) {
      case 'INACTIVE':
        return 'Inactive';
      case 'SCHEDULED':
        return 'Scheduled';
      case 'EXPIRED':
        return 'Expired';
      case 'ACTIVE':
      default:
        return 'Active';
    }
  }

  String get targetLabelText {
    final cleanTargetValue = _cleanNullableText(targetValue);
    final cleanTargetLabel = _cleanNullableText(targetLabel);

    if (targetType == BannerTargetType.none) {
      return 'No target';
    }

    if (targetType == BannerTargetType.url) {
      return cleanTargetValue ?? 'URL not set';
    }

    if (cleanTargetLabel != null) {
      return cleanTargetLabel;
    }

    if (cleanTargetValue != null) {
      return '${targetType.label} ID: $cleanTargetValue';
    }

    return '${targetType.label} not selected';
  }

  String get validityLabel {
    if (startsAt == null && expiresAt == null) {
      return 'No validity dates';
    }

    final from = startsAt == null ? 'No start' : _formatShortDate(startsAt!);
    final to = expiresAt == null ? 'No end' : _formatShortDate(expiresAt!);

    return '$from → $to';
  }

  BannerEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    BannerTargetType? targetType,
    String? targetValue,
    String? targetLabel,
    int? sortOrder,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      targetLabel: targetLabel ?? this.targetLabel,
      sortOrder: sortOrder ?? this.sortOrder,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String? _cleanNullableText(String? value) {
    if (value == null) return null;

    final text = value.trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        imageUrl,
        targetType,
        targetValue,
        targetLabel,
        sortOrder,
        startsAt,
        expiresAt,
        active,
        createdAt,
        updatedAt,
      ];
}