enum SupplierCatalogStatus {
  active,
  inactive,
}

class SupplierCategoryEntity {
  final String id;
  final String name;
  final SupplierCatalogStatus status;
  final int productCount;
  final int subCategoryCount;
  final bool canDelete;

  SupplierCategoryEntity({
    required this.id,
    required this.name,
    this.status = SupplierCatalogStatus.active,
    this.productCount = 0,
    this.subCategoryCount = 0,
    this.canDelete = true,
  });

  bool get isActive => status == SupplierCatalogStatus.active;
}
