import '../domain/entities/supplier_category_entity.dart';
import '../domain/entities/supplier_sub_category_entity.dart';

class SupplierCategoryMockStore {
  SupplierCategoryMockStore._();

  static final List<SupplierCategoryEntity> categories = [
    const SupplierCategoryEntity(
      id: 'cat_food_beverages',
      name: 'Food & Beverages',
    ),
    const SupplierCategoryEntity(
      id: 'cat_clothing',
      name: 'Clothing',
    ),
    const SupplierCategoryEntity(
      id: 'cat_electronics',
      name: 'Electronics',
    ),
    const SupplierCategoryEntity(
      id: 'cat_cosmetics',
      name: 'Cosmetics & Personal Care',
    ),
    const SupplierCategoryEntity(
      id: 'cat_construction',
      name: 'Construction Materials',
    ),
    const SupplierCategoryEntity(
      id: 'cat_household',
      name: 'Household Supplies',
    ),
  ];

  static final List<SupplierSubCategoryEntity> subCategories = [
    const SupplierSubCategoryEntity(
      id: 'sub_beverages',
      categoryId: 'cat_food_beverages',
      name: 'Beverages',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_snacks',
      categoryId: 'cat_food_beverages',
      name: 'Snacks',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_canned_goods',
      categoryId: 'cat_food_beverages',
      name: 'Canned Goods',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_men_clothing',
      categoryId: 'cat_clothing',
      name: 'Men Clothing',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_women_clothing',
      categoryId: 'cat_clothing',
      name: 'Women Clothing',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_kids_clothing',
      categoryId: 'cat_clothing',
      name: 'Kids Clothing',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_mobile_accessories',
      categoryId: 'cat_electronics',
      name: 'Mobile Accessories',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_home_appliances',
      categoryId: 'cat_electronics',
      name: 'Home Appliances',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_skincare',
      categoryId: 'cat_cosmetics',
      name: 'Skin Care',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_makeup',
      categoryId: 'cat_cosmetics',
      name: 'Makeup',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_cement',
      categoryId: 'cat_construction',
      name: 'Cement & Concrete',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_tools',
      categoryId: 'cat_construction',
      name: 'Tools',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_cleaning',
      categoryId: 'cat_household',
      name: 'Cleaning Supplies',
    ),
    const SupplierSubCategoryEntity(
      id: 'sub_disposables',
      categoryId: 'cat_household',
      name: 'Disposable Goods',
    ),
  ];

  static List<SupplierSubCategoryEntity> getSubCategoriesByCategoryId(
    String categoryId,
  ) {
    return subCategories
        .where((subCategory) => subCategory.categoryId == categoryId)
        .toList();
  }

  static SupplierCategoryEntity? getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  static SupplierSubCategoryEntity? getSubCategoryById(String? subCategoryId) {
    if (subCategoryId == null) return null;

    try {
      return subCategories.firstWhere(
        (subCategory) => subCategory.id == subCategoryId,
      );
    } catch (_) {
      return null;
    }
  }

  static SupplierCategoryEntity addCategory(String name) {
    final category = SupplierCategoryEntity(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
    );

    categories.add(category);
    return category;
  }

  static SupplierSubCategoryEntity addSubCategory({
    required String categoryId,
    required String name,
  }) {
    final subCategory = SupplierSubCategoryEntity(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: categoryId,
      name: name.trim(),
    );

    subCategories.add(subCategory);
    return subCategory;
  }
}