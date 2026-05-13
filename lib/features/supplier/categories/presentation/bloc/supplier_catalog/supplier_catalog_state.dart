import 'package:equatable/equatable.dart';

import '../../../domain/entities/supplier_category_entity.dart';
import '../../../domain/entities/supplier_sub_category_entity.dart';

class SupplierCatalogState extends Equatable {
  final bool isLoading;
  final bool isSaving;

  final List<SupplierCategoryEntity> categories;
  final List<SupplierSubCategoryEntity> subCategories;

  final String? error;
  final String? successMessage;

  SupplierCatalogState({
    required this.isLoading,
    required this.isSaving,
    required this.categories,
    required this.subCategories,
    this.error,
    this.successMessage,
  });

  factory SupplierCatalogState.initial() {
    return SupplierCatalogState(
      isLoading: false,
      isSaving: false,
      categories: [],
      subCategories: [],
    );
  }

  SupplierCatalogState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<SupplierCategoryEntity>? categories,
    List<SupplierSubCategoryEntity>? subCategories,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return SupplierCatalogState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      categories: categories ?? this.categories,
      subCategories: subCategories ?? this.subCategories,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        categories,
        subCategories,
        error,
        successMessage,
      ];
}

