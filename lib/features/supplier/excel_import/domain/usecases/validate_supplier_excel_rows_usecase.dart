import '../../../categories/domain/entities/supplier_category_entity.dart';
import '../../../categories/domain/entities/supplier_sub_category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../entities/supplier_excel_product_row_entity.dart';

class ValidateSupplierExcelRowsUseCase {
  List<SupplierExcelProductRowEntity> call({
    required List<SupplierExcelProductRowEntity> rows,
    required List<SupplierCategoryEntity> categories,
    required Map<String, List<SupplierSubCategoryEntity>> subCategoriesByCategoryId,
    List<ProductEntity> existingProducts = const [],
  }) {
    final duplicateNamesInExcel = _findDuplicateNamesInExcel(rows);
    final existingProductNames = existingProducts
        .map((product) => _normalize(product.name))
        .where((name) => name.isNotEmpty)
        .toSet();

    return rows.map((row) {
      final errors = <String>[];
      final warnings = <String>[];

      final productName = row.productName.trim();
      final description = row.description.trim();
      final categoryName = row.categoryName.trim();
      final subCategoryName = row.subCategoryName.trim();
      final price = _parseDouble(row.priceText);
      final moq = _parseInt(row.moqText);
      final status = _parseStatus(row.statusText);

      if (productName.isEmpty) {
        errors.add('Product Name is required.');
      } else {
        final normalizedProductName = _normalize(productName);

        if (duplicateNamesInExcel.contains(normalizedProductName)) {
          errors.add('Duplicate product name in this Excel file. Keep only one row for "$productName".');
        }

        if (existingProductNames.contains(normalizedProductName)) {
          errors.add('Product "$productName" already exists. Rename it or remove this row to avoid duplicates.');
        }
      }

      if (description.isEmpty) {
        errors.add('Description is required.');
      } else if (description.length < 10) {
        errors.add('Description must be at least 10 characters.');
      }

      SupplierCategoryEntity? matchedCategory;
      if (categoryName.isEmpty) {
        errors.add('Category is required.');
      } else {
        matchedCategory = _findCategoryByName(categories, categoryName);
        if (matchedCategory == null) {
          errors.add('Category "$categoryName" does not exist.');
        }
      }

      SupplierSubCategoryEntity? matchedSubCategory;
      if (subCategoryName.isNotEmpty && matchedCategory != null) {
        final subCategories = subCategoriesByCategoryId[matchedCategory.id] ?? [];
        matchedSubCategory = _findSubCategoryByName(
          subCategories,
          subCategoryName,
        );

        if (matchedSubCategory == null) {
          errors.add(
            'SubCategory "$subCategoryName" does not exist under "$categoryName".',
          );
        }
      }

      if (subCategoryName.isEmpty) {
        warnings.add('SubCategory is empty. Product will be created without subcategory.');
      }

      if (price == null) {
        errors.add('Price is required and must be a valid number.');
      } else if (price <= 0) {
        errors.add('Price must be greater than 0.');
      }

      if (moq == null) {
        errors.add('MOQ is required and must be a valid number.');
      } else if (moq < 5) {
        errors.add('MOQ must be at least 5.');
      }

      if (status == null) {
        errors.add('Status must be ACTIVE or INACTIVE.');
      }

      return row.copyWith(
        categoryId: matchedCategory?.id,
        subCategoryId: matchedSubCategory?.id,
        clearSubCategoryId: matchedSubCategory == null,
        price: price,
        minimumOrderQuantity: moq,
        status: status,
        errors: errors,
        warnings: warnings,
      );
    }).toList();
  }

  Set<String> _findDuplicateNamesInExcel(
    List<SupplierExcelProductRowEntity> rows,
  ) {
    final counts = <String, int>{};

    for (final row in rows) {
      final normalizedName = _normalize(row.productName);
      if (normalizedName.isEmpty) continue;

      counts[normalizedName] = (counts[normalizedName] ?? 0) + 1;
    }

    return counts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toSet();
  }

  SupplierCategoryEntity? _findCategoryByName(
    List<SupplierCategoryEntity> categories,
    String name,
  ) {
    final normalizedName = _normalize(name);
    for (final category in categories) {
      if (_normalize(category.name) == normalizedName) {
        return category;
      }
    }
    return null;
  }

  SupplierSubCategoryEntity? _findSubCategoryByName(
    List<SupplierSubCategoryEntity> subCategories,
    String name,
  ) {
    final normalizedName = _normalize(name);
    for (final subCategory in subCategories) {
      if (_normalize(subCategory.name) == normalizedName) {
        return subCategory;
      }
    }
    return null;
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  int? _parseInt(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;

    final intValue = int.tryParse(normalized);
    if (intValue != null) return intValue;

    final doubleValue = double.tryParse(normalized.replaceAll(',', '.'));
    if (doubleValue == null) return null;

    return doubleValue.round();
  }

  ProductStatus? _parseStatus(String value) {
    final normalized = value.trim().toUpperCase();
    if (normalized == 'ACTIVE') return ProductStatus.active;
    if (normalized == 'INACTIVE') return ProductStatus.inactive;
    return null;
  }
}
