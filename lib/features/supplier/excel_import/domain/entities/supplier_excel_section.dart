enum SupplierExcelSection {
  categories,
  subCategories,
  branches,
  products,
  inventory,
  taxRules,
  shippingMethods,
  coupons,
}

extension SupplierExcelSectionX on SupplierExcelSection {
  /// This follows the Build4All e-commerce Excel Import idea:
  /// one official workbook template, validation first, then import.
  /// Wholesale adds Branches and BranchInventory because stock is branch-based.
  static const List<SupplierExcelSection> importSections = [
    SupplierExcelSection.categories,
    SupplierExcelSection.subCategories,
    SupplierExcelSection.branches,
    SupplierExcelSection.products,
    SupplierExcelSection.inventory,
    SupplierExcelSection.taxRules,
    SupplierExcelSection.shippingMethods,
    SupplierExcelSection.coupons,
  ];

  String get sheetName {
    switch (this) {
      case SupplierExcelSection.categories:
        return 'Categories';
      case SupplierExcelSection.subCategories:
        return 'SubCategories';
      case SupplierExcelSection.branches:
        return 'Branches';
      case SupplierExcelSection.products:
        return 'Products';
      case SupplierExcelSection.inventory:
        return 'BranchInventory';
      case SupplierExcelSection.taxRules:
        return 'TaxRules';
      case SupplierExcelSection.shippingMethods:
        return 'ShippingMethods';
      case SupplierExcelSection.coupons:
        return 'Coupons';
    }
  }

  String get templateTitle {
    switch (this) {
      case SupplierExcelSection.categories:
        return 'Categories';
      case SupplierExcelSection.subCategories:
        return 'SubCategories';
      case SupplierExcelSection.branches:
        return 'Branches';
      case SupplierExcelSection.products:
        return 'Products';
      case SupplierExcelSection.inventory:
        return 'Branch Inventory';
      case SupplierExcelSection.taxRules:
        return 'Tax Rules';
      case SupplierExcelSection.shippingMethods:
        return 'Shipping Methods';
      case SupplierExcelSection.coupons:
        return 'Coupons';
    }
  }

  static SupplierExcelSection? fromSheetName(String sheetName) {
    final normalized = sheetName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '');

    switch (normalized) {
      case 'category':
      case 'categories':
        return SupplierExcelSection.categories;
      case 'subcategory':
      case 'subcategories':
        return SupplierExcelSection.subCategories;
      case 'branches':
      case 'branch':
        return SupplierExcelSection.branches;
      case 'products':
      case 'product':
        return SupplierExcelSection.products;
      case 'stock':
      case 'inventory':
      case 'branchinventory':
      case 'branchstock':
        return SupplierExcelSection.inventory;
      case 'tax':
      case 'taxrule':
      case 'taxrules':
        return SupplierExcelSection.taxRules;
      case 'shipping':
      case 'shippingmethod':
      case 'shippingmethods':
        return SupplierExcelSection.shippingMethods;
      case 'coupon':
      case 'coupons':
        return SupplierExcelSection.coupons;
    }

    return null;
  }
}
