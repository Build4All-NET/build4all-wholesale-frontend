import '../entities/supplier_category_entity.dart';
import '../entities/supplier_sub_category_entity.dart';

abstract class SupplierCategoryRepository {
  Future<List<SupplierCategoryEntity>> getCategories();

  Future<SupplierCategoryEntity> createCategory({
    required String name,
  });

  Future<SupplierCategoryEntity> updateCategory({
    required String categoryId,
    required String name,
  });

  Future<void> deleteCategory({
    required String categoryId,
  });

  Future<List<SupplierSubCategoryEntity>> getSubCategories();

  Future<List<SupplierSubCategoryEntity>> getSubCategoriesByCategory({
    required String categoryId,
  });

  Future<SupplierSubCategoryEntity> createSubCategory({
    required String categoryId,
    required String name,
  });

  Future<SupplierSubCategoryEntity> updateSubCategory({
    required String subCategoryId,
    required String name,
  });

  Future<void> deleteSubCategory({
    required String subCategoryId,
  });
}