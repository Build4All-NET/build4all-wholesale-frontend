import '../../domain/entities/supplier_category_entity.dart';
import '../../domain/entities/supplier_sub_category_entity.dart';
import '../../domain/repositories/supplier_category_repository.dart';
import '../services/supplier_category_api_service.dart';

class SupplierCategoryRepositoryImpl implements SupplierCategoryRepository {
  final SupplierCategoryApiService apiService;

  SupplierCategoryRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<List<SupplierCategoryEntity>> getCategories() {
    return apiService.getCategories();
  }

  @override
  Future<SupplierCategoryEntity> createCategory({
    required String name,
  }) {
    return apiService.createCategory(name: name);
  }

  @override
  Future<SupplierCategoryEntity> updateCategory({
    required String categoryId,
    required String name,
  }) {
    return apiService.updateCategory(
      categoryId: categoryId,
      name: name,
    );
  }

  @override
  Future<void> deleteCategory({
    required String categoryId,
  }) {
    return apiService.deleteCategory(categoryId: categoryId);
  }

  @override
  Future<List<SupplierSubCategoryEntity>> getSubCategories() {
    return apiService.getSubCategories();
  }

  @override
  Future<List<SupplierSubCategoryEntity>> getSubCategoriesByCategory({
    required String categoryId,
  }) {
    return apiService.getSubCategoriesByCategory(categoryId: categoryId);
  }

  @override
  Future<SupplierSubCategoryEntity> createSubCategory({
    required String categoryId,
    required String name,
  }) {
    return apiService.createSubCategory(
      categoryId: categoryId,
      name: name,
    );
  }

  @override
  Future<SupplierSubCategoryEntity> updateSubCategory({
    required String subCategoryId,
    required String name,
  }) {
    return apiService.updateSubCategory(
      subCategoryId: subCategoryId,
      name: name,
    );
  }

  @override
  Future<void> deleteSubCategory({
    required String subCategoryId,
  }) {
    return apiService.deleteSubCategory(subCategoryId: subCategoryId);
  }
}