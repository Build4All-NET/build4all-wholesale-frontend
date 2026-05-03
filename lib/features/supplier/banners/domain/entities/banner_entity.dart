enum BannerTargetType {
  none,
  product,
  category,
  customLink,
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
      case BannerTargetType.customLink:
        return 'Custom Link';
    }
  }
}

class BannerEntity {
  final String id;
  final int ownerProjectId;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final BannerTargetType targetType;
  final String? targetValue;
  final int displayOrder;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool active;

  const BannerEntity({
    required this.id,
    required this.ownerProjectId,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.targetType,
    this.targetValue,
    required this.displayOrder,
    this.startsAt,
    this.endsAt,
    required this.active,
  });

  bool get started {
    if (startsAt == null) return true;
    return !DateTime.now().isBefore(startsAt!);
  }

  bool get expired {
    if (endsAt == null) return false;
    return DateTime.now().isAfter(endsAt!);
  }

  bool get currentlyVisible {
    return active && started && !expired;
  }

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

  String get targetLabel {
    if (targetType == BannerTargetType.none) {
      return 'No target';
    }

    if (targetValue == null || targetValue!.trim().isEmpty) {
      return targetType.label;
    }

    return '${targetType.label}: $targetValue';
  }

  BannerEntity copyWith({
    String? id,
    int? ownerProjectId,
    String? title,
    String? subtitle,
    String? imageUrl,
    BannerTargetType? targetType,
    String? targetValue,
    int? displayOrder,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? active,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      ownerProjectId: ownerProjectId ?? this.ownerProjectId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      displayOrder: displayOrder ?? this.displayOrder,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      active: active ?? this.active,
    );
  }
}