import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    super.subtitle,
    required super.imageUrl,
    required super.targetType,
    super.targetValue,
    super.targetLabel,
    required super.sortOrder,
    super.startsAt,
    super.expiresAt,
    required super.active,
    super.createdAt,
    super.updatedAt,
  });

  factory BannerModel.fromEntity(BannerEntity entity) {
    return BannerModel(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      imageUrl: entity.imageUrl,
      targetType: entity.targetType,
      targetValue: entity.targetValue,
      targetLabel: entity.targetLabel,
      sortOrder: entity.sortOrder,
      startsAt: entity.startsAt,
      expiresAt: entity.expiresAt,
      active: entity.active,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory BannerModel.fromBackendJson(Map<String, dynamic> json) {
    final backendTargetType = BannerTargetTypeX.fromBackend(
      json['targetType']?.toString(),
    );

    final targetValue = _firstNullableString(json, [
      'targetValue',
      'targetId',
      'productId',
      'categoryId',
      'subCategoryId',
      'subcategoryId',
    ]);

    final targetLabel = _firstNullableString(json, [
      'targetLabel',
      'targetName',
      'productName',
      'categoryName',
      'subCategoryName',
      'subcategoryName',
    ]);

    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: _toNullableString(json['subtitle']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      targetType: backendTargetType,
      targetValue: targetValue,
      targetLabel: targetLabel,
      sortOrder: _toInt(json['sortOrder']) ?? 0,
      startsAt: _toDateTime(json['startDate']),
      expiresAt: _toDateTime(json['endDate']),
      active: json['active'] == true,
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toBackendCreateJson() {
    return {
      'title': title.trim(),
      'subtitle': subtitle == null || subtitle!.trim().isEmpty
          ? null
          : subtitle!.trim(),
      'imageUrl': imageUrl.trim(),
      'targetType': targetType.backendValue,
      'targetValue': targetType == BannerTargetType.none
          ? null
          : targetValue == null || targetValue!.trim().isEmpty
              ? null
              : targetValue!.trim(),
      'sortOrder': sortOrder,
      'startDate': startsAt?.toIso8601String(),
      'endDate': expiresAt?.toIso8601String(),
      'active': active,
    };
  }

  BannerEntity toEntity() {
    return BannerEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      targetType: targetType,
      targetValue: targetValue,
      targetLabel: targetLabel,
      sortOrder: sortOrder,
      startsAt: startsAt,
      expiresAt: expiresAt,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String? _firstNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _toNullableString(json[key]);

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}