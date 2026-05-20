import '../../../branches/domain/entities/branch_entity.dart';
import '../../../branches/domain/entities/branch_inventory_item_entity.dart';
import '../../../branches/domain/usecases/assign_product_to_branch_usecase.dart';
import '../../../branches/domain/usecases/create_branch_usecase.dart';
import '../../../branches/domain/usecases/get_branches_usecase.dart';
import '../../../branches/domain/usecases/get_inventory_by_branch_usecase.dart';
import '../../../branches/domain/usecases/update_branch_stock_usecase.dart';
import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../categories/domain/usecases/create_category_usecase.dart';
import '../../../categories/domain/usecases/create_subcategory_usecase.dart';
import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../categories/domain/usecases/get_subcategories_by_category_usecase.dart';
import '../../../coupons/domain/entities/coupon_entity.dart';
import '../../../coupons/domain/usecases/create_coupon_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/usecases/create_product_usecase.dart';
import '../../../products/domain/usecases/get_products_usecase.dart';
import '../../../shipping/domain/entities/shipping_method_entity.dart';
import '../../../shipping/domain/usecases/create_shipping_method_usecase.dart';
import '../../../tax/domain/entities/tax_rule_entity.dart';
import '../../../tax/domain/usecases/create_tax_rule_usecase.dart';
import '../entities/supplier_excel_import_result_entity.dart';
import '../entities/supplier_excel_parsed_file_entity.dart';
import '../entities/supplier_excel_row_entity.dart';
import '../entities/supplier_excel_section.dart';

class ImportSupplierExcelProductsUseCase {
  final CreateCategoryUseCase createCategoryUseCase;
  final CreateSubCategoryUseCase createSubCategoryUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubCategoriesByCategoryUseCase getSubCategoriesByCategoryUseCase;
  final CreateBranchUseCase createBranchUseCase;
  final GetBranchesUseCase getBranchesUseCase;
  final CreateProductUseCase createProductUseCase;
  final GetProductsUseCase getProductsUseCase;
  final AssignProductToBranchUseCase assignProductToBranchUseCase;
  final GetInventoryByBranchUseCase getInventoryByBranchUseCase;
  final UpdateBranchStockUseCase updateBranchStockUseCase;
  final CreateShippingMethodUseCase createShippingMethodUseCase;
  final CreateTaxRuleUseCase createTaxRuleUseCase;
  final CreateCouponUseCase createCouponUseCase;

  ImportSupplierExcelProductsUseCase({
    required this.createCategoryUseCase,
    required this.createSubCategoryUseCase,
    required this.getCategoriesUseCase,
    required this.getSubCategoriesByCategoryUseCase,
    required this.createBranchUseCase,
    required this.getBranchesUseCase,
    required this.createProductUseCase,
    required this.getProductsUseCase,
    required this.assignProductToBranchUseCase,
    required this.getInventoryByBranchUseCase,
    required this.updateBranchStockUseCase,
    required this.createShippingMethodUseCase,
    required this.createTaxRuleUseCase,
    required this.createCouponUseCase,
  });

  Future<SupplierExcelImportResultEntity> call({
    required SupplierExcelParsedFileEntity parsedFile,
  }) async {
    final messages = <String>[];
    final failedMessages = <String>[];
    var importedCount = 0;

    var categoriesByName = await _loadCategoriesByName();
    final subCategoriesByCategory = await _loadSubCategories(categoriesByName.values);
    var branchesByName = await _loadBranchesByName();
    var productsByName = await _loadProductsByName();

    Future<void> runRow(
      SupplierExcelRowEntity row,
      Future<void> Function() action,
    ) async {
      if (!row.isValid) {
        failedMessages.add(
          '${row.section.templateTitle} row ${row.rowNumber}: ${row.errors.join(' ')}',
        );
        return;
      }

      try {
        await action();
        importedCount++;
      } catch (error) {
        failedMessages.add(
          '${row.section.templateTitle} row ${row.rowNumber}: ${_message(error)}',
        );
      }
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.categories)) {
      await runRow(row, () async {
        final name = row.value('Name').trim();
        final key = _n(name);

        if (categoriesByName.containsKey(key)) {
          messages.add('Category "$name" already exists. Skipped.');
          return;
        }

        final created = await createCategoryUseCase(name: name);
        categoriesByName[key] = created;
        subCategoriesByCategory[created.id] = <SupplierSubCategoryEntity>[];
        messages.add('Category "$name" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.subCategories)) {
      await runRow(row, () async {
        final categoryName = row.value('Category').trim();
        final subCategoryName = row.value('SubCategory').trim();
        final category = categoriesByName[_n(categoryName)];

        if (category == null) {
          throw Exception('Category "$categoryName" was not found.');
        }

        final existing = (subCategoriesByCategory[category.id] ?? const <SupplierSubCategoryEntity>[])
            .where((subCategory) => _n(subCategory.name) == _n(subCategoryName))
            .cast<SupplierSubCategoryEntity?>()
            .firstWhere((subCategory) => subCategory != null, orElse: () => null);

        if (existing != null) {
          messages.add('SubCategory "$subCategoryName" already exists. Skipped.');
          return;
        }

        final created = await createSubCategoryUseCase(
          categoryId: category.id,
          name: subCategoryName,
        );

        subCategoriesByCategory.putIfAbsent(category.id, () => <SupplierSubCategoryEntity>[]).add(created);
        messages.add('SubCategory "$subCategoryName" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.branches)) {
      await runRow(row, () async {
        final name = row.value('Branch Name').trim();
        final key = _n(name);

        if (branchesByName.containsKey(key)) {
          messages.add('Branch "$name" already exists. Skipped.');
          return;
        }

        final created = await createBranchUseCase(
          name: name,
          countryCode: row.value('Country Code').trim().toUpperCase(),
          regionId: _int(row.value('Region ID')),
          city: row.value('City').trim(),
          address: row.value('Address').trim(),
          phoneNumber: row.value('Phone').trim(),
          status: _branchStatus(row.value('Status')),
        );

        branchesByName[key] = created;
        messages.add('Branch "$name" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.products)) {
      await runRow(row, () async {
        final name = row.value('Product Name').trim();
        final key = _n(name);

        if (productsByName.containsKey(key)) {
          messages.add('Product "$name" already exists. Skipped.');
          return;
        }

        final category = categoriesByName[_n(row.value('Category'))];
        if (category == null) {
          throw Exception('Category "${row.value('Category')}" was not found.');
        }

        final subCategoryName = row.value('SubCategory').trim();
        String? subCategoryId;

        if (subCategoryName.isNotEmpty) {
          final subCategory = (subCategoriesByCategory[category.id] ?? const <SupplierSubCategoryEntity>[])
              .where((item) => _n(item.name) == _n(subCategoryName))
              .cast<SupplierSubCategoryEntity?>()
              .firstWhere((item) => item != null, orElse: () => null);
          subCategoryId = subCategory?.id;
        }

        final created = await createProductUseCase(
          name: name,
          description: row.value('Description').trim(),
          categoryId: category.id,
          subCategoryId: subCategoryId,
          price: _double(row.value('Price')) ?? 0,
          minimumOrderQuantity: _int(row.value('MOQ')) ?? 5,
          status: _productStatus(row.value('Status')),
          imagePath: _clean(row.value('Image Url')),
        );

        productsByName[key] = created;
        messages.add('Product "$name" imported.');
      });
    }

    productsByName = await _loadProductsByName();

    for (final row in parsedFile.rowsFor(SupplierExcelSection.inventory)) {
      await runRow(row, () async {
        final branchName = row.value('Branch').trim();
        final productName = row.value('Product Name').trim();
        final branch = branchesByName[_n(branchName)];
        final product = productsByName[_n(productName)];

        if (branch == null) throw Exception('Branch "$branchName" was not found.');
        if (product == null) throw Exception('Product "$productName" was not found.');

        final stock = _int(row.value('Stock Quantity')) ?? 0;
        final existingInventory = await _findInventory(
          branchId: branch.id,
          productId: product.id,
        );

        if (existingInventory == null) {
          await assignProductToBranchUseCase(
            branchId: branch.id,
            productId: product.id,
            stockQuantity: stock,
          );
        } else {
          await updateBranchStockUseCase(
            inventoryId: existingInventory.id,
            stockQuantity: stock,
          );
        }

        messages.add('Stock for "$productName" in "$branchName" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.taxRules)) {
      await runRow(row, () async {
        final now = DateTime.now();

        await createTaxRuleUseCase(
          TaxRuleEntity(
            id: '',
            ruleName: row.value('Rule Name').trim(),
            rate: _double(row.value('Rate')) ?? 0,
            countryId: row.value('Country ID').trim(),
            countryName: row.value('Country Name').trim(),
            regionId: _clean(row.value('Region ID')),
            regionName: _clean(row.value('Region Name')),
            appliesToShipping: _bool(row.value('Applies To Shipping'), defaultValue: false),
            active: _bool(row.value('Active'), defaultValue: true),
            status: _bool(row.value('Active'), defaultValue: true) ? 'ACTIVE' : 'INACTIVE',
            notes: _clean(row.value('Notes')),
            createdAt: now,
            updatedAt: now,
          ),
        );

        messages.add('Tax rule "${row.value('Rule Name')}" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.shippingMethods)) {
      await runRow(row, () async {
        final now = DateTime.now();

        await createShippingMethodUseCase(
          ShippingMethodEntity(
            id: '',
            name: row.value('Name').trim(),
            methodType: _shippingType(row.value('Type')),
            countryId: _clean(row.value('Country ID')),
            countryName: _clean(row.value('Country Name')),
            regionId: _clean(row.value('Region ID')),
            regionName: _clean(row.value('Region Name')),
            cost: _double(row.value('Cost')) ?? 0,
            estimatedDeliveryTime: row.value('Estimated Delivery Time').trim(),
            minimumOrderAmount: _double(row.value('Minimum Order Amount')),
            freeShippingThreshold: _double(row.value('Free Shipping Threshold')),
            branchScope: _shippingBranchScope(row.value('Branch Scope')),
            selectedBranchIds: _branchIdsFromNames(row.value('Branch Names'), branchesByName),
            selectedBranchNames: _branchNamesFromNames(row.value('Branch Names'), branchesByName),
            active: _bool(row.value('Active'), defaultValue: true),
            status: _bool(row.value('Active'), defaultValue: true) ? 'ACTIVE' : 'INACTIVE',
            notes: _clean(row.value('Notes')),
            createdAt: now,
            updatedAt: now,
          ),
        );

        messages.add('Shipping method "${row.value('Name')}" imported.');
      });
    }

    for (final row in parsedFile.rowsFor(SupplierExcelSection.coupons)) {
      await runRow(row, () async {
        await createCouponUseCase(
          CouponEntity(
            id: '',
            ownerProjectId: 0,
            code: row.value('Code').trim().toUpperCase(),
            description: _clean(row.value('Description')),
            discountType: _couponDiscountType(row.value('Discount Type')),
            discountValue: _double(row.value('Discount Value')) ?? 0,
            maxUses: _int(row.value('Max Uses')),
            minOrderAmount: _double(row.value('Min Order Amount')),
            maxDiscountAmount: _double(row.value('Max Discount Amount')),
            startsAt: _date(row.value('Starts At')),
            expiresAt: _date(row.value('Expires At')),
            active: _bool(row.value('Active'), defaultValue: true),
            branchScope: _couponBranchScope(row.value('Branch Scope')),
            selectedBranchIds: _branchIdsFromNames(row.value('Branch Names'), branchesByName),
            selectedBranchNames: _branchNamesFromNames(row.value('Branch Names'), branchesByName),
          ),
        );

        messages.add('Coupon "${row.value('Code')}" imported.');
      });
    }

    return SupplierExcelImportResultEntity(
      totalRows: parsedFile.totalRows,
      importedCount: importedCount,
      failedCount: failedMessages.length,
      messages: messages,
      failedMessages: failedMessages,
    );
  }

  Future<Map<String, SupplierCategoryEntity>> _loadCategoriesByName() async {
    final categories = await getCategoriesUseCase();
    return {
      for (final category in categories) _n(category.name): category,
    };
  }

  Future<Map<String, List<SupplierSubCategoryEntity>>> _loadSubCategories(
    Iterable<SupplierCategoryEntity> categories,
  ) async {
    final result = <String, List<SupplierSubCategoryEntity>>{};

    for (final category in categories) {
      result[category.id] = await getSubCategoriesByCategoryUseCase(categoryId: category.id);
    }

    return result;
  }

  Future<Map<String, BranchEntity>> _loadBranchesByName() async {
    final branches = await getBranchesUseCase();
    return {
      for (final branch in branches) _n(branch.name): branch,
    };
  }

  Future<Map<String, ProductEntity>> _loadProductsByName() async {
    final products = await getProductsUseCase();
    return {
      for (final product in products) _n(product.name): product,
    };
  }

  Future<BranchInventoryItemEntity?> _findInventory({
    required String branchId,
    required String productId,
  }) async {
    final items = await getInventoryByBranchUseCase(branchId: branchId);

    return items
        .where((item) => item.productId == productId)
        .cast<BranchInventoryItemEntity?>()
        .firstWhere((item) => item != null, orElse: () => null);
  }

  List<String> _branchIdsFromNames(
    String rawNames,
    Map<String, BranchEntity> branchesByName,
  ) {
    if (_n(rawNames).isEmpty || _n(rawNames) == 'all') return const [];

    return rawNames
        .split(RegExp(r'[,;]'))
        .map((name) => branchesByName[_n(name)])
        .whereType<BranchEntity>()
        .map((branch) => branch.id)
        .toList();
  }

  List<String> _branchNamesFromNames(
    String rawNames,
    Map<String, BranchEntity> branchesByName,
  ) {
    if (_n(rawNames).isEmpty || _n(rawNames) == 'all') return const [];

    return rawNames
        .split(RegExp(r'[,;]'))
        .map((name) => branchesByName[_n(name)])
        .whereType<BranchEntity>()
        .map((branch) => branch.name)
        .toList();
  }

  BranchStatus _branchStatus(String value) {
    return _n(value) == 'inactive' ? BranchStatus.inactive : BranchStatus.active;
  }

  ProductStatus _productStatus(String value) {
    return _n(value) == 'inactive' ? ProductStatus.inactive : ProductStatus.active;
  }

  ShippingMethodType _shippingType(String value) {
    final normalized = _n(value);
    if (normalized == 'express' || normalized == 'expressdelivery') {
      return ShippingMethodType.expressDelivery;
    }
    if (normalized == 'pickup') return ShippingMethodType.pickup;
    return ShippingMethodType.standardDelivery;
  }

  ShippingBranchScope _shippingBranchScope(String value) {
    return _n(value).contains('selected')
        ? ShippingBranchScope.selectedBranches
        : ShippingBranchScope.allBranches;
  }

  CouponDiscountType _couponDiscountType(String value) {
    final normalized = _n(value);
    if (normalized == 'fixed') return CouponDiscountType.fixed;
    if (normalized == 'freeshipping') return CouponDiscountType.freeShipping;
    return CouponDiscountType.percent;
  }

  CouponBranchScope _couponBranchScope(String value) {
    return _n(value).contains('selected')
        ? CouponBranchScope.selectedBranches
        : CouponBranchScope.allBranches;
  }

  bool _bool(String value, {required bool defaultValue}) {
    final normalized = _n(value);
    if (normalized.isEmpty) return defaultValue;
    return ['true', 'yes', '1', 'active', 'enabled'].contains(normalized);
  }

  double? _double(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  int? _int(String value) {
    final numeric = double.tryParse(value.trim().replaceAll(',', '.'));
    return numeric?.round();
  }

  DateTime? _date(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;

    final excelNumber = double.tryParse(text);
    if (excelNumber != null && excelNumber > 0) {
      return DateTime(1899, 12, 30).add(Duration(days: excelNumber.round()));
    }

    final parts = text.split(RegExp(r'[\/\-]'));
    if (parts.length == 3) {
      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      final third = int.tryParse(parts[2]);

      if (first != null && second != null && third != null) {
        if (parts[0].length == 4) return DateTime(first, second, third);
        if (parts[2].length == 4) return DateTime(third, second, first);
      }
    }

    return null;
  }

  String? _clean(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String _n(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
