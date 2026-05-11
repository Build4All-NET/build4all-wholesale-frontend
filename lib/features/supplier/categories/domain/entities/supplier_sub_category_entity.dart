import 'supplier_category_entity.dart';

class SupplierSubCategoryEntity {
  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final SupplierCatalogStatus status;
  final int productCount;
  final bool canDelete;

  const SupplierSubCategoryEntity({
    required this.id,
    required this.categoryId,
    this.categoryName = '',
    required this.name,
    this.status = SupplierCatalogStatus.active,
    this.productCount = 0,
    this.canDelete = true,
  });

  bool get isActive => status == SupplierCatalogStatus.active;
}
