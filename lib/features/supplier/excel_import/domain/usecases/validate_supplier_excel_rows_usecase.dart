import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../entities/supplier_excel_parsed_file_entity.dart';
import '../entities/supplier_excel_row_entity.dart';
import '../entities/supplier_excel_section.dart';

class ValidateSupplierExcelRowsUseCase {
  SupplierExcelParsedFileEntity call({
    required SupplierExcelParsedFileEntity parsedFile,
    required List<SupplierCategoryEntity> categories,
    required Map<String, List<SupplierSubCategoryEntity>> subCategoriesByCategoryId,
    required List<ProductEntity> existingProducts,
    required List<BranchEntity> existingBranches,
  }) {
    final existingCategoryNames = {
      for (final category in categories) _n(category.name): category,
    };

    final existingProductNames = {
      for (final product in existingProducts) _n(product.name): product,
    };

    final existingBranchNames = {
      for (final branch in existingBranches) _n(branch.name): branch,
    };

    final excelCategoryNames = parsedFile
        .rowsFor(SupplierExcelSection.categories)
        .map((row) => _n(row.value('Name')))
        .where((name) => name.isNotEmpty)
        .toSet();

    final excelSubCategoryByCategory = <String, Set<String>>{};
    for (final row in parsedFile.rowsFor(SupplierExcelSection.subCategories)) {
      final categoryName = _n(row.value('Category'));
      final subCategoryName = _n(row.value('SubCategory'));
      if (categoryName.isEmpty || subCategoryName.isEmpty) continue;
      excelSubCategoryByCategory.putIfAbsent(categoryName, () => <String>{}).add(subCategoryName);
    }

    final excelProductNames = parsedFile
        .rowsFor(SupplierExcelSection.products)
        .map((row) => _n(row.value('Product Name')))
        .where((name) => name.isNotEmpty)
        .toSet();

    final excelBranchNames = parsedFile
        .rowsFor(SupplierExcelSection.branches)
        .map((row) => _n(row.value('Branch Name')))
        .where((name) => name.isNotEmpty)
        .toSet();

    final duplicateProductNames = _duplicates(
      parsedFile.rowsFor(SupplierExcelSection.products).map((row) => row.value('Product Name')),
    );

    final duplicateBranchNames = _duplicates(
      parsedFile.rowsFor(SupplierExcelSection.branches).map((row) => row.value('Branch Name')),
    );

    final duplicateCategoryNames = _duplicates(
      parsedFile.rowsFor(SupplierExcelSection.categories).map((row) => row.value('Name')),
    );

    final duplicateInventoryPairs = _duplicatePairs(
      parsedFile.rowsFor(SupplierExcelSection.inventory).map(
            (row) => '${row.value('Branch')}|||${row.value('Product Name')}',
          ),
    );

    final updated = <SupplierExcelSection, List<SupplierExcelRowEntity>>{};

    for (final section in SupplierExcelSection.values) {
      updated[section] = parsedFile.rowsFor(section).map((row) {
        final errors = <String>[];
        final warnings = <String>[];

        switch (section) {
          case SupplierExcelSection.categories:
            _validateCategory(row, errors, warnings, duplicateCategoryNames);
            break;
          case SupplierExcelSection.subCategories:
            _validateSubCategory(
              row,
              errors,
              warnings,
              existingCategoryNames: existingCategoryNames.keys.toSet(),
              excelCategoryNames: excelCategoryNames,
            );
            break;
          case SupplierExcelSection.branches:
            _validateBranch(row, errors, warnings, duplicateBranchNames);
            break;
          case SupplierExcelSection.products:
            _validateProduct(
              row,
              errors,
              warnings,
              existingCategoryNames: existingCategoryNames.keys.toSet(),
              excelCategoryNames: excelCategoryNames,
              excelSubCategoryByCategory: excelSubCategoryByCategory,
              subCategoriesByCategoryId: subCategoriesByCategoryId,
              categories: categories,
              existingProductNames: existingProductNames.keys.toSet(),
              duplicateProductNames: duplicateProductNames,
            );
            break;
          case SupplierExcelSection.inventory:
            _validateInventory(
              row,
              errors,
              warnings,
              existingProductNames: existingProductNames.keys.toSet(),
              excelProductNames: excelProductNames,
              existingBranchNames: existingBranchNames.keys.toSet(),
              excelBranchNames: excelBranchNames,
              duplicateInventoryPairs: duplicateInventoryPairs,
            );
            break;
          case SupplierExcelSection.shippingMethods:
            _validateShipping(row, errors, warnings);
            break;
          case SupplierExcelSection.taxRules:
            _validateTax(row, errors, warnings);
            break;
          case SupplierExcelSection.coupons:
            _validateCoupon(row, errors, warnings);
            break;
        }

        return row.copyWith(errors: errors, warnings: warnings);
      }).toList(growable: false);
    }

    updated.removeWhere((_, rows) => rows.isEmpty);

    return parsedFile.copyWith(rowsBySection: updated);
  }

  void _validateCategory(
    SupplierExcelRowEntity row,
    List<String> errors,
    List<String> warnings,
    Set<String> duplicateCategoryNames,
  ) {
    final name = row.value('Name');
    if (name.trim().isEmpty) {
      errors.add('Category name is required.');
    } else if (duplicateCategoryNames.contains(_n(name))) {
      errors.add('This category name is duplicated in the Excel file.');
    }

    _validateStatus(row.value('Status'), errors, fieldName: 'Status');
  }

  void _validateSubCategory(
    SupplierExcelRowEntity row,
    List<String> errors,
    List<String> warnings, {
    required Set<String> existingCategoryNames,
    required Set<String> excelCategoryNames,
  }) {
    final categoryName = _n(row.value('Category'));
    final subCategoryName = row.value('SubCategory');

    if (categoryName.isEmpty) {
      errors.add('Category is required.');
    } else if (!existingCategoryNames.contains(categoryName) &&
        !excelCategoryNames.contains(categoryName)) {
      errors.add('Category was not found. Add it in the Categories sheet or create it first.');
    }

    if (subCategoryName.trim().isEmpty) {
      errors.add('SubCategory name is required.');
    }

    _validateStatus(row.value('Status'), errors, fieldName: 'Status');
  }

  void _validateBranch(
    SupplierExcelRowEntity row,
    List<String> errors,
    List<String> warnings,
    Set<String> duplicateBranchNames,
  ) {
    final name = row.value('Branch Name');
    final countryCode = row.value('Country Code');
    final city = row.value('City');
    final address = row.value('Address');
    final phone = row.value('Phone');

    if (name.trim().isEmpty) errors.add('Branch name is required.');
    if (countryCode.trim().isEmpty) errors.add('Country code is required.');
    if (city.trim().isEmpty) errors.add('City is required.');
    if (address.trim().isEmpty) errors.add('Address is required.');
    if (phone.trim().isEmpty) errors.add('Phone is required.');
    if (duplicateBranchNames.contains(_n(name))) {
      errors.add('This branch name is duplicated in the Excel file.');
    }

    if (row.optionalValue('Region ID') != null && _int(row.value('Region ID')) == null) {
      errors.add('Region ID must be a valid number.');
    }

    _validateStatus(row.value('Status'), errors, fieldName: 'Status');
  }

  void _validateProduct(
    SupplierExcelRowEntity row,
    List<String> errors,
    List<String> warnings, {
    required Set<String> existingCategoryNames,
    required Set<String> excelCategoryNames,
    required Map<String, Set<String>> excelSubCategoryByCategory,
    required Map<String, List<SupplierSubCategoryEntity>> subCategoriesByCategoryId,
    required List<SupplierCategoryEntity> categories,
    required Set<String> existingProductNames,
    required Set<String> duplicateProductNames,
  }) {
    final name = row.value('Product Name');
    final categoryName = _n(row.value('Category'));
    final subCategoryName = _n(row.value('SubCategory'));
    final price = _double(row.value('Price'));
    final moq = _int(row.value('MOQ'));

    if (name.trim().isEmpty) {
      errors.add('Product name is required.');
    } else {
      final normalizedName = _n(name);

      if (existingProductNames.contains(normalizedName)) {
        errors.add('A product with this name already exists.');
      }

      if (duplicateProductNames.contains(normalizedName)) {
        errors.add('This product name is duplicated in the Excel file.');
      }
    }

    if (row.value('Description').trim().length < 10) {
      errors.add('Description must contain at least 10 characters.');
    }

    if (categoryName.isEmpty) {
      errors.add('Category is required.');
    } else if (!existingCategoryNames.contains(categoryName) &&
        !excelCategoryNames.contains(categoryName)) {
      errors.add('Category was not found. Add it in the Categories sheet or create it first.');
    }

    if (subCategoryName.isNotEmpty) {
      final category = categories
          .where((item) => _n(item.name) == categoryName)
          .cast<SupplierCategoryEntity?>()
          .firstWhere((item) => item != null, orElse: () => null);

      final existingSubNames = category == null
          ? <String>{}
          : (subCategoriesByCategoryId[category.id] ?? const <SupplierSubCategoryEntity>[])
              .map((item) => _n(item.name))
              .toSet();

      final excelSubNames = excelSubCategoryByCategory[categoryName] ?? const <String>{};

      if (!existingSubNames.contains(subCategoryName) && !excelSubNames.contains(subCategoryName)) {
        warnings.add('SubCategory was not found. The product will be imported without a subcategory unless it exists in the SubCategories sheet.');
      }
    }

    if (price == null || price <= 0) {
      errors.add('Price must be greater than zero.');
    }

    if (moq == null || moq < 5) {
      errors.add('MOQ must be at least 5.');
    }

    _validateStatus(row.value('Status'), errors, fieldName: 'Status');
  }

  void _validateInventory(
    SupplierExcelRowEntity row,
    List<String> errors,
    List<String> warnings, {
    required Set<String> existingProductNames,
    required Set<String> excelProductNames,
    required Set<String> existingBranchNames,
    required Set<String> excelBranchNames,
    required Set<String> duplicateInventoryPairs,
  }) {
    final branch = _n(row.value('Branch'));
    final product = _n(row.value('Product Name'));
    final stock = _int(row.value('Stock Quantity'));

    if (branch.isEmpty) {
      errors.add('Branch is required.');
    } else if (!existingBranchNames.contains(branch) && !excelBranchNames.contains(branch)) {
      errors.add('Branch was not found. Add it in the Branches sheet or create it first.');
    }

    if (product.isEmpty) {
      errors.add('Product name is required.');
    } else if (!existingProductNames.contains(product) && !excelProductNames.contains(product)) {
      errors.add('Product was not found. Add it in the Products sheet or create it first.');
    }

    if (stock == null || stock < 0) {
      errors.add('Stock quantity must be zero or greater.');
    }

    final pairKey = _pairKey(row.value('Branch'), row.value('Product Name'));
    if (pairKey.isNotEmpty && duplicateInventoryPairs.contains(pairKey)) {
      errors.add('This branch/product stock row is duplicated in the Excel file.');
    }
  }

  void _validateShipping(
    SupplierExcelRowEntity row,
    List<String> errors,
    List<String> warnings,
  ) {
    if (row.value('Name').trim().isEmpty) errors.add('Shipping method name is required.');
    if (!_isOneOf(row.value('Type'), ['standard', 'express', 'pickup'])) {
      errors.add('Type must be STANDARD, EXPRESS, or PICKUP.');
    }

    final cost = _double(row.value('Cost'));
    if (cost == null || cost < 0) errors.add('Cost must be zero or greater.');

    final minOrder = _double(row.value('Minimum Order Amount'));
    if (row.value('Minimum Order Amount').trim().isNotEmpty &&
        (minOrder == null || minOrder < 0)) {
      errors.add('Minimum Order Amount must be zero or greater.');
    }

    final freeThreshold = _double(row.value('Free Shipping Threshold'));
    if (row.value('Free Shipping Threshold').trim().isNotEmpty &&
        (freeThreshold == null || freeThreshold < 0)) {
      errors.add('Free Shipping Threshold must be zero or greater.');
    }

    if (row.value('Estimated Delivery Time').trim().isEmpty) {
      errors.add('Estimated delivery time is required.');
    }

    _validateBool(row.value('Active'), errors, fieldName: 'Active');
  }

  void _validateTax(
    SupplierExcelRowEntity row,
    List<String> errors,
    List<String> warnings,
  ) {
    if (row.value('Rule Name').trim().isEmpty) errors.add('Rule name is required.');

    final rate = _double(row.value('Rate'));
    if (rate == null || rate < 0 || rate > 100) {
      errors.add('Rate must be between 0 and 100.');
    }

    if (row.value('Country ID').trim().isEmpty) errors.add('Country ID is required.');
    if (_int(row.value('Country ID')) == null) errors.add('Country ID must be a valid number.');
    if (row.value('Country Name').trim().isEmpty) errors.add('Country name is required.');

    _validateBool(row.value('Applies To Shipping'), errors, fieldName: 'Applies To Shipping');
    _validateBool(row.value('Active'), errors, fieldName: 'Active');
  }

  void _validateCoupon(
    SupplierExcelRowEntity row,
    List<String> errors,
    List<String> warnings,
  ) {
    if (row.value('Code').trim().isEmpty) errors.add('Coupon code is required.');

    if (!_isOneOf(row.value('Discount Type'), ['percent', 'percentage', 'fixed', 'freeshipping'])) {
      errors.add('Discount Type must be PERCENT, FIXED, or FREE_SHIPPING.');
    }

    final value = _double(row.value('Discount Value'));
    if (value == null || value < 0) errors.add('Discount value must be zero or greater.');

    final maxUses = _int(row.value('Max Uses'));
    if (row.value('Max Uses').trim().isNotEmpty &&
        (maxUses == null || maxUses <= 0)) {
      errors.add('Max Uses must be greater than zero.');
    }

    _validatePositiveOptional(row.value('Min Order Amount'), errors, 'Min Order Amount');
    _validatePositiveOptional(row.value('Max Discount Amount'), errors, 'Max Discount Amount');
    _validateDateRange(
      row.value('Starts At'),
      row.value('Expires At'),
      errors,
      startLabel: 'Starts At',
      endLabel: 'Expires At',
    );
    _validateBool(row.value('Active'), errors, fieldName: 'Active');
  }

  void _validateStatus(String value, List<String> errors, {required String fieldName}) {
    if (value.trim().isEmpty) return;
    if (!_isOneOf(value, ['active', 'inactive'])) {
      errors.add('$fieldName must be ACTIVE or INACTIVE.');
    }
  }

  void _validateBool(String value, List<String> errors, {required String fieldName}) {
    if (value.trim().isEmpty) return;
    if (!_isOneOf(value, ['true', 'false', 'yes', 'no', '1', '0', 'active', 'inactive'])) {
      errors.add('$fieldName must be TRUE/FALSE, YES/NO, or ACTIVE/INACTIVE.');
    }
  }

  void _validatePositiveOptional(String value, List<String> errors, String fieldName) {
    if (value.trim().isEmpty) return;
    final number = _double(value);
    if (number == null || number < 0) {
      errors.add('$fieldName must be zero or greater.');
    }
  }

  void _validateDateRange(
    String start,
    String end,
    List<String> errors, {
    required String startLabel,
    required String endLabel,
  }) {
    final startDate = _date(start);
    final endDate = _date(end);

    if (start.trim().isNotEmpty && startDate == null) {
      errors.add('$startLabel must be a valid date, for example 2026-05-25.');
    }

    if (end.trim().isNotEmpty && endDate == null) {
      errors.add('$endLabel must be a valid date, for example 2026-05-25.');
    }

    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      errors.add('$endLabel must be after $startLabel.');
    }
  }

  Set<String> _duplicates(Iterable<String> values) {
    final seen = <String>{};
    final duplicate = <String>{};

    for (final value in values) {
      final normalized = _n(value);
      if (normalized.isEmpty) continue;
      if (!seen.add(normalized)) duplicate.add(normalized);
    }

    return duplicate;
  }

  Set<String> _duplicatePairs(Iterable<String> values) {
    final seen = <String>{};
    final duplicate = <String>{};

    for (final value in values) {
      final parts = value.split('|||');
      if (parts.length != 2) continue;
      final normalized = _pairKey(parts[0], parts[1]);
      if (normalized.isEmpty) continue;
      if (!seen.add(normalized)) duplicate.add(normalized);
    }

    return duplicate;
  }

  String _pairKey(String first, String second) {
    final a = _n(first);
    final b = _n(second);
    if (a.isEmpty || b.isEmpty) return '';
    return '$a|||$b';
  }

  bool _isOneOf(String value, List<String> allowed) {
    final normalized = _n(value);
    if (normalized.isEmpty) return true;
    return allowed.map(_n).contains(normalized);
  }

  String _n(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
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
}
