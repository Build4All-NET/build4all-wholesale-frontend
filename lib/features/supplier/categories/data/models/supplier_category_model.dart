import '../../domain/entities/supplier_category_entity.dart';

class SupplierCategoryModel extends SupplierCategoryEntity {
  const SupplierCategoryModel({
    required super.id,
    required super.name,
    super.status,
    super.productCount,
    super.subCategoryCount,
    super.canDelete,
  });

  factory SupplierCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupplierCategoryModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      status: _statusFromJson(json['status']),
      productCount: _toInt(json['productCount']),
      subCategoryCount: _toInt(json['subCategoryCount']),
      canDelete: _toBool(json['canDelete']),
    );
  }

  static SupplierCatalogStatus _statusFromJson(dynamic value) {
    final status = value?.toString().toUpperCase();

    if (status == 'INACTIVE') {
      return SupplierCatalogStatus.inactive;
    }

    return SupplierCatalogStatus.active;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }
}
