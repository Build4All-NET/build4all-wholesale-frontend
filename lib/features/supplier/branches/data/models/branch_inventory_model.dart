import '../../domain/entities/branch_inventory_item_entity.dart';

class BranchInventoryModel extends BranchInventoryItemEntity {
  const BranchInventoryModel({
    required super.id,
    required super.branchId,
    required super.productId,
    required super.productName,
    required super.categoryName,
    super.subCategoryName,
    required super.stockQuantity,
  });

  factory BranchInventoryModel.fromJson(Map<String, dynamic> json) {
    return BranchInventoryModel(
      id: json['id'].toString(),
      branchId: json['branchId'].toString(),
      productId: json['productId'].toString(),
      productName: json['productName']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      subCategoryName: json['subCategoryName']?.toString(),
      stockQuantity:
          int.tryParse(json['stockQuantity']?.toString() ?? '0') ?? 0,
    );
  }
}