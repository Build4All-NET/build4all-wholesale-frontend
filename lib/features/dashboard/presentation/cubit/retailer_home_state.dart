import 'package:equatable/equatable.dart';

import '../../data/models/retailer_home_model.dart';

class RetailerHomeState extends Equatable {
  final bool isLoading;

  final bool isFeaturedProductsLoading;
  final bool isFeaturedProductsLoadingMore;
  final List<HomeProductModel> featuredProductsList;
  final int featuredProductsPage;
  final bool featuredProductsHasMore;
  final String featuredProductsSearchQuery;

  final bool isCategoryProductsLoading;
  final bool isCategoryProductsLoadingMore;
  final List<HomeProductModel> categoryProducts;
  final HomeCategoryModel? selectedCategory;
  final int categoryProductsPage;
  final bool categoryProductsHasMore;
  final int? categoryProductsSubCategoryId;
  final String categoryProductsSearchQuery;

  final bool isPromotionsLoading;
  final bool isPromotionsLoadingMore;
  final List<HomeProductModel> promotedProducts;
  final int promotionsPage;
  final bool promotionsHasMore;

  final bool isSearchLoading;
  final bool isSearchLoadingMore;
  final List<HomeProductModel> searchResults;
  final String searchQuery;
  final bool hasSearched;
  final int searchPage;
  final bool searchHasMore;

  final bool isBannerTargetLoading;
  final bool isBannerTargetLoadingMore;
  final List<HomeProductModel> bannerTargetProducts;
  final int bannerTargetPage;
  final bool bannerTargetHasMore;

  final int? addingProductId;

  final RetailerHomeModel? home;
  final String? errorMessage;
  final String? successMessage;

  const RetailerHomeState({
    this.isLoading = false,
    this.isFeaturedProductsLoading = false,
    this.isFeaturedProductsLoadingMore = false,
    this.featuredProductsList = const [],
    this.featuredProductsPage = 0,
    this.featuredProductsHasMore = true,
    this.featuredProductsSearchQuery = '',
    this.isCategoryProductsLoading = false,
    this.isCategoryProductsLoadingMore = false,
    this.categoryProducts = const [],
    this.selectedCategory,
    this.categoryProductsPage = 0,
    this.categoryProductsHasMore = true,
    this.categoryProductsSubCategoryId,
    this.categoryProductsSearchQuery = '',
    this.isPromotionsLoading = false,
    this.isPromotionsLoadingMore = false,
    this.promotedProducts = const [],
    this.promotionsPage = 0,
    this.promotionsHasMore = true,
    this.isSearchLoading = false,
    this.isSearchLoadingMore = false,
    this.searchResults = const [],
    this.searchQuery = '',
    this.hasSearched = false,
    this.searchPage = 0,
    this.searchHasMore = true,
    this.isBannerTargetLoading = false,
    this.isBannerTargetLoadingMore = false,
    this.bannerTargetProducts = const [],
    this.bannerTargetPage = 0,
    this.bannerTargetHasMore = true,
    this.addingProductId,
    this.home,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAddingToCart => addingProductId != null;

  RetailerHomeState copyWith({
    bool? isLoading,
    bool? isFeaturedProductsLoading,
    bool? isFeaturedProductsLoadingMore,
    List<HomeProductModel>? featuredProductsList,
    int? featuredProductsPage,
    bool? featuredProductsHasMore,
    String? featuredProductsSearchQuery,
    bool? isCategoryProductsLoading,
    bool? isCategoryProductsLoadingMore,
    List<HomeProductModel>? categoryProducts,
    HomeCategoryModel? selectedCategory,
    bool clearSelectedCategory = false,
    int? categoryProductsPage,
    bool? categoryProductsHasMore,
    int? categoryProductsSubCategoryId,
    bool clearCategoryProductsSubCategoryId = false,
    String? categoryProductsSearchQuery,
    bool? isPromotionsLoading,
    bool? isPromotionsLoadingMore,
    List<HomeProductModel>? promotedProducts,
    int? promotionsPage,
    bool? promotionsHasMore,
    bool? isSearchLoading,
    bool? isSearchLoadingMore,
    List<HomeProductModel>? searchResults,
    String? searchQuery,
    bool? hasSearched,
    int? searchPage,
    bool? searchHasMore,
    bool? isBannerTargetLoading,
    bool? isBannerTargetLoadingMore,
    List<HomeProductModel>? bannerTargetProducts,
    int? bannerTargetPage,
    bool? bannerTargetHasMore,
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
      isFeaturedProductsLoading:
          isFeaturedProductsLoading ?? this.isFeaturedProductsLoading,
      isFeaturedProductsLoadingMore:
          isFeaturedProductsLoadingMore ?? this.isFeaturedProductsLoadingMore,
      featuredProductsList: featuredProductsList ?? this.featuredProductsList,
      featuredProductsPage: featuredProductsPage ?? this.featuredProductsPage,
      featuredProductsHasMore:
          featuredProductsHasMore ?? this.featuredProductsHasMore,
      featuredProductsSearchQuery:
          featuredProductsSearchQuery ?? this.featuredProductsSearchQuery,
      isCategoryProductsLoading:
          isCategoryProductsLoading ?? this.isCategoryProductsLoading,
      isCategoryProductsLoadingMore:
          isCategoryProductsLoadingMore ?? this.isCategoryProductsLoadingMore,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      categoryProductsPage: categoryProductsPage ?? this.categoryProductsPage,
      categoryProductsHasMore:
          categoryProductsHasMore ?? this.categoryProductsHasMore,
      categoryProductsSubCategoryId: clearCategoryProductsSubCategoryId
          ? null
          : (categoryProductsSubCategoryId ??
              this.categoryProductsSubCategoryId),
      categoryProductsSearchQuery:
          categoryProductsSearchQuery ?? this.categoryProductsSearchQuery,
      isPromotionsLoading: isPromotionsLoading ?? this.isPromotionsLoading,
      isPromotionsLoadingMore:
          isPromotionsLoadingMore ?? this.isPromotionsLoadingMore,
      promotedProducts: promotedProducts ?? this.promotedProducts,
      promotionsPage: promotionsPage ?? this.promotionsPage,
      promotionsHasMore: promotionsHasMore ?? this.promotionsHasMore,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      isSearchLoadingMore: isSearchLoadingMore ?? this.isSearchLoadingMore,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      hasSearched: hasSearched ?? this.hasSearched,
      searchPage: searchPage ?? this.searchPage,
      searchHasMore: searchHasMore ?? this.searchHasMore,
      isBannerTargetLoading:
          isBannerTargetLoading ?? this.isBannerTargetLoading,
      isBannerTargetLoadingMore:
          isBannerTargetLoadingMore ?? this.isBannerTargetLoadingMore,
      bannerTargetProducts: bannerTargetProducts ?? this.bannerTargetProducts,
      bannerTargetPage: bannerTargetPage ?? this.bannerTargetPage,
      bannerTargetHasMore: bannerTargetHasMore ?? this.bannerTargetHasMore,
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
    isFeaturedProductsLoading,
    isFeaturedProductsLoadingMore,
    featuredProductsList,
    featuredProductsPage,
    featuredProductsHasMore,
    featuredProductsSearchQuery,
    isCategoryProductsLoading,
    isCategoryProductsLoadingMore,
    categoryProducts,
    selectedCategory,
    categoryProductsPage,
    categoryProductsHasMore,
    categoryProductsSubCategoryId,
    categoryProductsSearchQuery,
    isPromotionsLoading,
    isPromotionsLoadingMore,
    promotedProducts,
    promotionsPage,
    promotionsHasMore,
    isSearchLoading,
    isSearchLoadingMore,
    searchResults,
    searchQuery,
    hasSearched,
    searchPage,
    searchHasMore,
    isBannerTargetLoading,
    isBannerTargetLoadingMore,
    bannerTargetProducts,
    bannerTargetPage,
    bannerTargetHasMore,
    addingProductId,
    home,
    errorMessage,
    successMessage,
  ];
}
