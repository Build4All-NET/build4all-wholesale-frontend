import 'package:equatable/equatable.dart';

import '../../data/models/retailer_home_model.dart';

class RetailerHomeState extends Equatable {
  final bool isLoading;

  final bool isCategoryProductsLoading;
  final List<HomeProductModel> categoryProducts;
  final HomeCategoryModel? selectedCategory;

  final bool isPromotionsLoading;
  final List<HomeProductModel> promotedProducts;

  final bool isSearchLoading;
  final List<HomeProductModel> searchResults;
  final String searchQuery;
  final bool hasSearched;

  final int? addingProductId;

  final RetailerHomeModel? home;
  final String? errorMessage;
  final String? successMessage;

  const RetailerHomeState({
    this.isLoading = false,
    this.isCategoryProductsLoading = false,
    this.categoryProducts = const [],
    this.selectedCategory,
    this.isPromotionsLoading = false,
    this.promotedProducts = const [],
    this.isSearchLoading = false,
    this.searchResults = const [],
    this.searchQuery = '',
    this.hasSearched = false,
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
    bool? isPromotionsLoading,
    List<HomeProductModel>? promotedProducts,
    bool? isSearchLoading,
    List<HomeProductModel>? searchResults,
    String? searchQuery,
    bool? hasSearched,
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
      isPromotionsLoading: isPromotionsLoading ?? this.isPromotionsLoading,
      promotedProducts: promotedProducts ?? this.promotedProducts,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      hasSearched: hasSearched ?? this.hasSearched,
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
    isPromotionsLoading,
    promotedProducts,
    isSearchLoading,
    searchResults,
    searchQuery,
    hasSearched,
    addingProductId,
    home,
    errorMessage,
    successMessage,
  ];
}
