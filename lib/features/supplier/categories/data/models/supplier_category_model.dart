import '../../domain/entities/supplier_category_entity.dart';

class SupplierCategoryModel extends SupplierCategoryEntity {
  const SupplierCategoryModel({
    required super.id,
    required super.name,
  });

  factory SupplierCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupplierCategoryModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}