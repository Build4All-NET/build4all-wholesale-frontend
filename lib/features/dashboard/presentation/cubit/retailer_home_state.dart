import 'package:equatable/equatable.dart';

import '../../data/models/retailer_home_model.dart';

class RetailerHomeState extends Equatable {
  final bool isLoading;

  final bool isAllProductsLoading;
  final bool isAllProductsLoadingMore;
  final List<HomeProductModel> allProducts;
  final int allProductsPage;
  final bool allProductsHasNext;
  final String allProductsSearchQuery;

  final bool isCategoryProductsLoading;
  final bool isCategoryProductsLoadingMore;
  final List<HomeProductModel> categoryProducts;
  final HomeCategoryModel? selectedCategory;
  final int? selectedSubCategoryId;
  final String categoryProductsSearchQuery;
  final int categoryProductsPage;
  final bool categoryProductsHasNext;

  final bool isPromotionsLoading;
  final bool isPromotionsLoadingMore;
  final List<HomeProductModel> promotedProducts;
  final String promotedProductsSearchQuery;
  final int promotedProductsPage;
  final bool promotedProductsHasNext;

  final bool isSearchLoading;
  final bool isSearchLoadingMore;
  final List<HomeProductModel> searchResults;
  final String searchQuery;
  final int searchPage;
  final bool searchHasNext;
  final bool hasSearched;

  final bool isBannerTargetLoading;
  final bool isBannerTargetLoadingMore;
  final List<HomeProductModel> bannerTargetProducts;
  final HomeBannerModel? selectedBanner;
  final String bannerTargetSearchQuery;
  final int bannerTargetPage;
  final bool bannerTargetHasNext;

  final int? addingProductId;

  final RetailerHomeModel? home;
  final String? errorMessage;
  final String? successMessage;

  const RetailerHomeState({
    this.isLoading = false,
    this.isAllProductsLoading = false,
    this.isAllProductsLoadingMore = false,
    this.allProducts = const [],
    this.allProductsPage = 0,
    this.allProductsHasNext = false,
    this.allProductsSearchQuery = '',
    this.isCategoryProductsLoading = false,
    this.isCategoryProductsLoadingMore = false,
    this.categoryProducts = const [],
    this.selectedCategory,
    this.selectedSubCategoryId,
    this.categoryProductsSearchQuery = '',
    this.categoryProductsPage = 0,
    this.categoryProductsHasNext = false,
    this.isPromotionsLoading = false,
    this.isPromotionsLoadingMore = false,
    this.promotedProducts = const [],
    this.promotedProductsSearchQuery = '',
    this.promotedProductsPage = 0,
    this.promotedProductsHasNext = false,
    this.isSearchLoading = false,
    this.isSearchLoadingMore = false,
    this.searchResults = const [],
    this.searchQuery = '',
    this.searchPage = 0,
    this.searchHasNext = false,
    this.hasSearched = false,
    this.isBannerTargetLoading = false,
    this.isBannerTargetLoadingMore = false,
    this.bannerTargetProducts = const [],
    this.selectedBanner,
    this.bannerTargetSearchQuery = '',
    this.bannerTargetPage = 0,
    this.bannerTargetHasNext = false,
    this.addingProductId,
    this.home,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAddingToCart => addingProductId != null;

  RetailerHomeState copyWith({
    bool? isLoading,
    bool? isAllProductsLoading,
    bool? isAllProductsLoadingMore,
    List<HomeProductModel>? allProducts,
    int? allProductsPage,
    bool? allProductsHasNext,
    String? allProductsSearchQuery,
    bool? isCategoryProductsLoading,
    bool? isCategoryProductsLoadingMore,
    List<HomeProductModel>? categoryProducts,
    HomeCategoryModel? selectedCategory,
    bool clearSelectedCategory = false,
    int? selectedSubCategoryId,
    bool clearSelectedSubCategoryId = false,
    String? categoryProductsSearchQuery,
    int? categoryProductsPage,
    bool? categoryProductsHasNext,
    bool? isPromotionsLoading,
    bool? isPromotionsLoadingMore,
    List<HomeProductModel>? promotedProducts,
    String? promotedProductsSearchQuery,
    int? promotedProductsPage,
    bool? promotedProductsHasNext,
    bool? isSearchLoading,
    bool? isSearchLoadingMore,
    List<HomeProductModel>? searchResults,
    String? searchQuery,
    int? searchPage,
    bool? searchHasNext,
    bool? hasSearched,
    bool? isBannerTargetLoading,
    bool? isBannerTargetLoadingMore,
    List<HomeProductModel>? bannerTargetProducts,
    HomeBannerModel? selectedBanner,
    bool clearSelectedBanner = false,
    String? bannerTargetSearchQuery,
    int? bannerTargetPage,
    bool? bannerTargetHasNext,
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
      isAllProductsLoading:
          isAllProductsLoading ?? this.isAllProductsLoading,
      isAllProductsLoadingMore:
          isAllProductsLoadingMore ?? this.isAllProductsLoadingMore,
      allProducts: allProducts ?? this.allProducts,
      allProductsPage: allProductsPage ?? this.allProductsPage,
      allProductsHasNext: allProductsHasNext ?? this.allProductsHasNext,
      allProductsSearchQuery:
          allProductsSearchQuery ?? this.allProductsSearchQuery,
      isCategoryProductsLoading:
          isCategoryProductsLoading ?? this.isCategoryProductsLoading,
      isCategoryProductsLoadingMore:
          isCategoryProductsLoadingMore ?? this.isCategoryProductsLoadingMore,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedSubCategoryId: clearSelectedSubCategoryId
          ? null
          : (selectedSubCategoryId ?? this.selectedSubCategoryId),
      categoryProductsSearchQuery:
          categoryProductsSearchQuery ?? this.categoryProductsSearchQuery,
      categoryProductsPage: categoryProductsPage ?? this.categoryProductsPage,
      categoryProductsHasNext:
          categoryProductsHasNext ?? this.categoryProductsHasNext,
      isPromotionsLoading: isPromotionsLoading ?? this.isPromotionsLoading,
      isPromotionsLoadingMore:
          isPromotionsLoadingMore ?? this.isPromotionsLoadingMore,
      promotedProducts: promotedProducts ?? this.promotedProducts,
      promotedProductsSearchQuery:
          promotedProductsSearchQuery ?? this.promotedProductsSearchQuery,
      promotedProductsPage: promotedProductsPage ?? this.promotedProductsPage,
      promotedProductsHasNext:
          promotedProductsHasNext ?? this.promotedProductsHasNext,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      isSearchLoadingMore: isSearchLoadingMore ?? this.isSearchLoadingMore,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      searchPage: searchPage ?? this.searchPage,
      searchHasNext: searchHasNext ?? this.searchHasNext,
      hasSearched: hasSearched ?? this.hasSearched,
      isBannerTargetLoading:
          isBannerTargetLoading ?? this.isBannerTargetLoading,
      isBannerTargetLoadingMore:
          isBannerTargetLoadingMore ?? this.isBannerTargetLoadingMore,
      bannerTargetProducts:
          bannerTargetProducts ?? this.bannerTargetProducts,
      selectedBanner: clearSelectedBanner
          ? null
          : (selectedBanner ?? this.selectedBanner),
      bannerTargetSearchQuery:
          bannerTargetSearchQuery ?? this.bannerTargetSearchQuery,
      bannerTargetPage: bannerTargetPage ?? this.bannerTargetPage,
      bannerTargetHasNext: bannerTargetHasNext ?? this.bannerTargetHasNext,
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
    isAllProductsLoading,
    isAllProductsLoadingMore,
    allProducts,
    allProductsPage,
    allProductsHasNext,
    allProductsSearchQuery,
    isCategoryProductsLoading,
    isCategoryProductsLoadingMore,
    categoryProducts,
    selectedCategory,
    selectedSubCategoryId,
    categoryProductsSearchQuery,
    categoryProductsPage,
    categoryProductsHasNext,
    isPromotionsLoading,
    isPromotionsLoadingMore,
    promotedProducts,
    promotedProductsSearchQuery,
    promotedProductsPage,
    promotedProductsHasNext,
    isSearchLoading,
    isSearchLoadingMore,
    searchResults,
    searchQuery,
    searchPage,
    searchHasNext,
    hasSearched,
    isBannerTargetLoading,
    isBannerTargetLoadingMore,
    bannerTargetProducts,
    selectedBanner,
    bannerTargetSearchQuery,
    bannerTargetPage,
    bannerTargetHasNext,
    addingProductId,
    home,
    errorMessage,
    successMessage,
  ];
}
