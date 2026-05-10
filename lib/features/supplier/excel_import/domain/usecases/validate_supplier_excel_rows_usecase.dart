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
        errors.add('Enter a product name before importing this row.');
      } else {
        final normalizedProductName = _normalize(productName);

        if (duplicateNamesInExcel.contains(normalizedProductName)) {
          errors.add(
            'This product name appears more than once in the Excel file. Keep one row only for "$productName".',
          );
        }

        if (existingProductNames.contains(normalizedProductName)) {
          errors.add(
            'A product named "$productName" already exists. This row is protected from duplicate import. Remove it from Excel, rename it, or edit the existing product from Product Management.',
          );
        }
      }

      if (description.isEmpty) {
        errors.add('Enter a product description before importing this row.');
      } else if (description.length < 10) {
        errors.add('Description must be at least 10 characters.');
      }

      SupplierCategoryEntity? matchedCategory;
      if (categoryName.isEmpty) {
        errors.add('Choose a category for this product.');
      } else {
        matchedCategory = _findCategoryByName(categories, categoryName);
        if (matchedCategory == null) {
          errors.add(
            'Category "$categoryName" was not found. Create it in Catalog or select an existing category from Edit Row.',
          );
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
            'Subcategory "$subCategoryName" was not found under "$categoryName". Create it in Catalog or choose an existing subcategory from Edit Row.',
          );
        }
      }

      if (price == null) {
        errors.add('Enter a valid product price.');
      } else if (price <= 0) {
        errors.add('Price must be greater than 0.');
      }

      if (moq == null) {
        errors.add('Enter a valid MOQ.');
      } else if (moq < 5) {
        errors.add('MOQ must be at least 5.');
      }

      if (status == null) {
        errors.add('Status must be ACTIVE or INACTIVE.');
      }

      return row.copyWith(
        categoryId: matchedCategory?.id,
        subCategoryId: matchedSubCategory?.id,
        clearCategoryId: matchedCategory == null,
        clearSubCategoryId: matchedSubCategory == null,
        price: price,
        minimumOrderQuantity: moq,
        status: status,
        clearParsedPrice: price == null,
        clearParsedMoq: moq == null,
        clearParsedStatus: status == null,
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
    if (normalized.isEmpty || normalized == '-') return null;
    return double.tryParse(normalized);
  }

  int? _parseInt(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == '-') return null;

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
