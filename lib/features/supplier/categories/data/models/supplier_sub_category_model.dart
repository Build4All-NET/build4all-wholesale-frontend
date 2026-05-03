import '../../domain/entities/supplier_sub_category_entity.dart';

class SupplierSubCategoryModel extends SupplierSubCategoryEntity {
  final String? categoryName;

  const SupplierSubCategoryModel({
    required super.id,
    required super.categoryId,
    required super.name,
    this.categoryName,
  });

  factory SupplierSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SupplierSubCategoryModel(
      id: json['id'].toString(),
      categoryId: json['categoryId'].toString(),
      categoryName: json['categoryName']?.toString(),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
    };
  }
}