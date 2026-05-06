import 'package:equatable/equatable.dart';

import '../../data/models/retailer_home_model.dart';

class RetailerHomeState extends Equatable {
  final bool isLoading;

  final bool isCategoryProductsLoading;
  final List<HomeProductModel> categoryProducts;
  final HomeCategoryModel? selectedCategory;

  final int? addingProductId;

  final RetailerHomeModel? home;
  final String? errorMessage;
  final String? successMessage;

  const RetailerHomeState({
    this.isLoading = false,
    this.isCategoryProductsLoading = false,
    this.categoryProducts = const [],
    this.selectedCategory,
    this.addingProductId,
    this.home,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAddingToCart => addingProductId != null;

  RetailerHomeState copyWith({
    bool? isLoading,
    bool? isCategoryProductsLoading,
    List<HomeProductModel>? categoryProducts,
    HomeCategoryModel? selectedCategory,
    bool clearSelectedCategory = false,
    int? addingProductId,
    bool clearAddingProductId = false,
    RetailerHomeModel? home,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return RetailerHomeState(
      isLoading: isLoading ?? this.isLoading,
      isCategoryProductsLoading:
          isCategoryProductsLoading ?? this.isCategoryProductsLoading,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      addingProductId: clearAddingProductId
          ? null
          : (addingProductId ?? this.addingProductId),
      home: home ?? this.home,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isCategoryProductsLoading,
    categoryProducts,
    selectedCategory,
    addingProductId,
    home,
    errorMessage,
    successMessage,
  ];
}
