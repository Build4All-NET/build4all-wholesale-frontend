import '../../domain/entities/branch_inventory_item_entity.dart';

class BranchInventoryItemModel extends BranchInventoryItemEntity {
  const BranchInventoryItemModel({
    required super.id,
    required super.branchId,
    required super.branchName,
    required super.branchCity,
    required super.productId,
    required super.productName,
    required super.categoryId,
    required super.categoryName,
    super.subCategoryId,
    super.subCategoryName,
    required super.stockQuantity,
  });

  factory BranchInventoryItemModel.fromJson(Map<String, dynamic> json) {
    return BranchInventoryItemModel(
      id: json['id'].toString(),
      branchId: json['branchId'].toString(),
      branchName: (json['branchName'] ?? '').toString(),
      branchCity: (json['branchCity'] ?? '').toString(),
      productId: json['productId'].toString(),
      productName: (json['productName'] ?? '').toString(),
      categoryId: json['categoryId'].toString(),
      categoryName: (json['categoryName'] ?? '').toString(),
      subCategoryId: json['subCategoryId']?.toString(),
      subCategoryName: json['subCategoryName']?.toString(),
      stockQuantity: _toInt(json['stockQuantity']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}