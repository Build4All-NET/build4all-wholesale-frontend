import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/utils/app_error_mapper.dart';

import '../../data/models/retailer_home_model.dart';
import '../../domain/repositories/retailer_home_repository.dart';
import 'retailer_home_state.dart';

class RetailerHomeCubit extends Cubit<RetailerHomeState> {
  final RetailerHomeRepository retailerHomeRepository;

  static const int _pageSize = 20;

  RetailerHomeCubit({required this.retailerHomeRepository})
    : super(const RetailerHomeState());

  Future<void> loadHome() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final home = await retailerHomeRepository.getHome();

      emit(state.copyWith(isLoading: false, home: home));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadAllProducts({String search = ''}) async {
    final trimmedSearch = search.trim();

    emit(
      state.copyWith(
        isAllProductsLoading: true,
        isAllProductsLoadingMore: false,
        allProducts: const [],
        allProductsPage: 0,
        allProductsHasNext: false,
        allProductsSearchQuery: trimmedSearch,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final page = await retailerHomeRepository.getProducts(
        page: 0,
        size: _pageSize,
        search: trimmedSearch,
      );

      if (state.allProductsSearchQuery != trimmedSearch) return;

      emit(
        state.copyWith(
          isAllProductsLoading: false,
          allProducts: page.products,
          allProductsPage: page.page,
          allProductsHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      if (state.allProductsSearchQuery != trimmedSearch) return;

      emit(
        state.copyWith(
          isAllProductsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMoreAllProducts() async {
    if (state.isAllProductsLoading ||
        state.isAllProductsLoadingMore ||
        !state.allProductsHasNext) {
      return;
    }

    final search = state.allProductsSearchQuery;
    final nextPage = state.allProductsPage + 1;

    emit(state.copyWith(isAllProductsLoadingMore: true, clearError: true));

    try {
      final page = await retailerHomeRepository.getProducts(
        page: nextPage,
        size: _pageSize,
        search: search,
      );

      if (state.allProductsSearchQuery != search) return;

      emit(
        state.copyWith(
          isAllProductsLoadingMore: false,
          allProducts: _mergeProducts(state.allProducts, page.products),
          allProductsPage: page.page,
          allProductsHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAllProductsLoadingMore: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadProductsByCategory({
    required HomeCategoryModel category,
    int? subCategoryId,
    String search = '',
  }) async {
    final trimmedSearch = search.trim();

    emit(
      state.copyWith(
        isCategoryProductsLoading: true,
        isCategoryProductsLoadingMore: false,
        selectedCategory: category,
        selectedSubCategoryId: subCategoryId,
        clearSelectedSubCategoryId: subCategoryId == null,
        categoryProducts: const [],
        categoryProductsPage: 0,
        categoryProductsHasNext: false,
        categoryProductsSearchQuery: trimmedSearch,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final page = await retailerHomeRepository.getProductsByCategory(
        categoryId: category.id,
        page: 0,
        size: _pageSize,
        search: trimmedSearch,
        subCategoryId: subCategoryId,
      );

      if (state.selectedCategory?.id != category.id ||
          state.selectedSubCategoryId != subCategoryId ||
          state.categoryProductsSearchQuery != trimmedSearch) {
        return;
      }

      emit(
        state.copyWith(
          isCategoryProductsLoading: false,
          categoryProducts: page.products,
          categoryProductsPage: page.page,
          categoryProductsHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      if (state.selectedCategory?.id != category.id) return;

      emit(
        state.copyWith(
          isCategoryProductsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMoreProductsByCategory() async {
    final category = state.selectedCategory;

    if (category == null ||
        state.isCategoryProductsLoading ||
        state.isCategoryProductsLoadingMore ||
        !state.categoryProductsHasNext) {
      return;
    }

    final subCategoryId = state.selectedSubCategoryId;
    final search = state.categoryProductsSearchQuery;
    final nextPage = state.categoryProductsPage + 1;

    emit(state.copyWith(isCategoryProductsLoadingMore: true, clearError: true));

    try {
      final page = await retailerHomeRepository.getProductsByCategory(
        categoryId: category.id,
        page: nextPage,
        size: _pageSize,
        search: search,
        subCategoryId: subCategoryId,
      );

      if (state.selectedCategory?.id != category.id ||
          state.selectedSubCategoryId != subCategoryId ||
          state.categoryProductsSearchQuery != search) {
        return;
      }

      emit(
        state.copyWith(
          isCategoryProductsLoadingMore: false,
          categoryProducts: _mergeProducts(state.categoryProducts, page.products),
          categoryProductsPage: page.page,
          categoryProductsHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isCategoryProductsLoadingMore: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadPromotedProducts({String search = ''}) async {
    final trimmedSearch = search.trim();

    emit(
      state.copyWith(
        isPromotionsLoading: true,
        isPromotionsLoadingMore: false,
        promotedProducts: const [],
        promotedProductsPage: 0,
        promotedProductsHasNext: false,
        promotedProductsSearchQuery: trimmedSearch,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final page = await retailerHomeRepository.getPromotedProducts(
        page: 0,
        size: _pageSize,
        search: trimmedSearch,
      );

      if (state.promotedProductsSearchQuery != trimmedSearch) return;

      emit(
        state.copyWith(
          isPromotionsLoading: false,
          promotedProducts: page.products,
          promotedProductsPage: page.page,
          promotedProductsHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      if (state.promotedProductsSearchQuery != trimmedSearch) return;

      emit(
        state.copyWith(
          isPromotionsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMorePromotedProducts() async {
    if (state.isPromotionsLoading ||
        state.isPromotionsLoadingMore ||
        !state.promotedProductsHasNext) {
      return;
    }

    final search = state.promotedProductsSearchQuery;
    final nextPage = state.promotedProductsPage + 1;

    emit(state.copyWith(isPromotionsLoadingMore: true, clearError: true));

    try {
      final page = await retailerHomeRepository.getPromotedProducts(
        page: nextPage,
        size: _pageSize,
        search: search,
      );

      if (state.promotedProductsSearchQuery != search) return;

      emit(
        state.copyWith(
          isPromotionsLoadingMore: false,
          promotedProducts: _mergeProducts(state.promotedProducts, page.products),
          promotedProductsPage: page.page,
          promotedProductsHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPromotionsLoadingMore: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> searchProducts({required String query}) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      emit(
        state.copyWith(
          isSearchLoading: false,
          isSearchLoadingMore: false,
          searchResults: const [],
          searchQuery: '',
          searchPage: 0,
          searchHasNext: false,
          hasSearched: false,
          clearError: true,
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSearchLoading: true,
        isSearchLoadingMore: false,
        searchResults: const [],
        searchQuery: trimmedQuery,
        searchPage: 0,
        searchHasNext: false,
        hasSearched: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final page = await retailerHomeRepository.searchProducts(
        query: trimmedQuery,
        page: 0,
        size: _pageSize,
      );

      if (state.searchQuery != trimmedQuery) return;

      emit(
        state.copyWith(
          isSearchLoading: false,
          searchResults: page.products,
          searchPage: page.page,
          searchHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      if (state.searchQuery != trimmedQuery) return;

      emit(
        state.copyWith(
          isSearchLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMoreSearchProducts() async {
    if (state.isSearchLoading ||
        state.isSearchLoadingMore ||
        !state.searchHasNext ||
        state.searchQuery.trim().isEmpty) {
      return;
    }

    final query = state.searchQuery;
    final nextPage = state.searchPage + 1;

    emit(state.copyWith(isSearchLoadingMore: true, clearError: true));

    try {
      final page = await retailerHomeRepository.searchProducts(
        query: query,
        page: nextPage,
        size: _pageSize,
      );

      if (state.searchQuery != query) return;

      emit(
        state.copyWith(
          isSearchLoadingMore: false,
          searchResults: _mergeProducts(state.searchResults, page.products),
          searchPage: page.page,
          searchHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSearchLoadingMore: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadBannerTargetProducts({
    required HomeBannerModel banner,
    String search = '',
  }) async {
    final trimmedSearch = search.trim();

    if (banner.targetType.trim().toUpperCase() == 'NONE') {
      emit(
        state.copyWith(
          isBannerTargetLoading: false,
          isBannerTargetLoadingMore: false,
          bannerTargetProducts: const [],
          selectedBanner: banner,
          bannerTargetSearchQuery: trimmedSearch,
          bannerTargetPage: 0,
          bannerTargetHasNext: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isBannerTargetLoading: true,
        isBannerTargetLoadingMore: false,
        bannerTargetProducts: const [],
        selectedBanner: banner,
        bannerTargetSearchQuery: trimmedSearch,
        bannerTargetPage: 0,
        bannerTargetHasNext: false,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final page = await retailerHomeRepository.getBannerTargetProducts(
        banner: banner,
        page: 0,
        size: _pageSize,
        search: trimmedSearch,
      );

      if (state.selectedBanner?.id != banner.id ||
          state.bannerTargetSearchQuery != trimmedSearch) {
        return;
      }

      emit(
        state.copyWith(
          isBannerTargetLoading: false,
          bannerTargetProducts: page.products,
          bannerTargetPage: page.page,
          bannerTargetHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      if (state.selectedBanner?.id != banner.id) return;

      emit(
        state.copyWith(
          isBannerTargetLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMoreBannerTargetProducts() async {
    final banner = state.selectedBanner;

    if (banner == null ||
        state.isBannerTargetLoading ||
        state.isBannerTargetLoadingMore ||
        !state.bannerTargetHasNext) {
      return;
    }

    final search = state.bannerTargetSearchQuery;
    final nextPage = state.bannerTargetPage + 1;

    emit(state.copyWith(isBannerTargetLoadingMore: true, clearError: true));

    try {
      final page = await retailerHomeRepository.getBannerTargetProducts(
        banner: banner,
        page: nextPage,
        size: _pageSize,
        search: search,
      );

      if (state.selectedBanner?.id != banner.id ||
          state.bannerTargetSearchQuery != search) {
        return;
      }

      emit(
        state.copyWith(
          isBannerTargetLoadingMore: false,
          bannerTargetProducts: _mergeProducts(
            state.bannerTargetProducts,
            page.products,
          ),
          bannerTargetPage: page.page,
          bannerTargetHasNext: page.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isBannerTargetLoadingMore: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> addToCart({required HomeProductModel product, int? quantity}) async {
    emit(
      state.copyWith(
        addingProductId: product.id,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      await retailerHomeRepository.addToCart(
        product: product,
        quantity: quantity,
      );

      RetailerHomeModel? refreshedHome;
      if (state.home != null) {
        refreshedHome = await retailerHomeRepository.getHome();
      }

      emit(
        state.copyWith(
          clearAddingProductId: true,
          home: refreshedHome,
          successMessage: 'PRODUCT_ADDED_TO_CART',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          clearAddingProductId: true,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  List<HomeProductModel> _mergeProducts(
    List<HomeProductModel> current,
    List<HomeProductModel> next,
  ) {
    final merged = <int, HomeProductModel>{};

    for (final product in current) {
      merged[product.id] = product;
    }

    for (final product in next) {
      merged[product.id] = product;
    }

    return merged.values.toList();
  }
}
