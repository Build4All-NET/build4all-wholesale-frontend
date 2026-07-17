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

  Future<void> loadFeaturedProducts({String? search}) async {
    emit(
      state.copyWith(
        isFeaturedProductsLoading: true,
        featuredProductsList: const [],
        featuredProductsPage: 0,
        featuredProductsHasMore: true,
        featuredProductsSearchQuery: search ?? '',
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await retailerHomeRepository.getFeaturedProducts(
        page: 0,
        size: _pageSize,
        search: search,
      );

      emit(
        state.copyWith(
          isFeaturedProductsLoading: false,
          featuredProductsList: result.content,
          featuredProductsPage: result.page,
          featuredProductsHasMore: result.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isFeaturedProductsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMoreFeaturedProducts() async {
    if (state.isFeaturedProductsLoadingMore || !state.featuredProductsHasMore) {
      return;
    }

    emit(state.copyWith(isFeaturedProductsLoadingMore: true));

    try {
      final nextPage = state.featuredProductsPage + 1;
      final result = await retailerHomeRepository.getFeaturedProducts(
        page: nextPage,
        size: _pageSize,
        search: state.featuredProductsSearchQuery.isEmpty
            ? null
            : state.featuredProductsSearchQuery,
      );

      emit(
        state.copyWith(
          isFeaturedProductsLoadingMore: false,
          featuredProductsList: [
            ...state.featuredProductsList,
            ...result.content,
          ],
          featuredProductsPage: result.page,
          featuredProductsHasMore: result.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isFeaturedProductsLoadingMore: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadProductsByCategory({
    required HomeCategoryModel category,
    int? subCategoryId,
    String? search,
  }) async {
    emit(
      state.copyWith(
        isCategoryProductsLoading: true,
        selectedCategory: category,
        categoryProducts: const [],
        categoryProductsPage: 0,
        categoryProductsHasMore: true,
        categoryProductsSubCategoryId: subCategoryId,
        clearCategoryProductsSubCategoryId: subCategoryId == null,
        categoryProductsSearchQuery: search ?? '',
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await retailerHomeRepository.getProductsByCategory(
        categoryId: category.id,
        subCategoryId: subCategoryId,
        search: search,
        page: 0,
        size: _pageSize,
      );

      emit(
        state.copyWith(
          isCategoryProductsLoading: false,
          categoryProducts: result.content,
          categoryProductsPage: result.page,
          categoryProductsHasMore: result.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isCategoryProductsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMoreCategoryProducts() async {
    if (state.isCategoryProductsLoadingMore || !state.categoryProductsHasMore) {
      return;
    }

    final category = state.selectedCategory;
    if (category == null) return;

    emit(state.copyWith(isCategoryProductsLoadingMore: true));

    try {
      final nextPage = state.categoryProductsPage + 1;
      final result = await retailerHomeRepository.getProductsByCategory(
        categoryId: category.id,
        subCategoryId: state.categoryProductsSubCategoryId,
        search: state.categoryProductsSearchQuery.isEmpty
            ? null
            : state.categoryProductsSearchQuery,
        page: nextPage,
        size: _pageSize,
      );

      emit(
        state.copyWith(
          isCategoryProductsLoadingMore: false,
          categoryProducts: [...state.categoryProducts, ...result.content],
          categoryProductsPage: result.page,
          categoryProductsHasMore: result.hasNext,
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

  Future<void> loadPromotedProducts() async {
    emit(
      state.copyWith(
        isPromotionsLoading: true,
        promotedProducts: const [],
        promotionsPage: 0,
        promotionsHasMore: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await retailerHomeRepository.getPromotedProducts(
        page: 0,
        size: _pageSize,
      );

      emit(
        state.copyWith(
          isPromotionsLoading: false,
          promotedProducts: result.content,
          promotionsPage: result.page,
          promotionsHasMore: result.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isPromotionsLoading: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMorePromotedProducts() async {
    if (state.isPromotionsLoadingMore || !state.promotionsHasMore) return;

    emit(state.copyWith(isPromotionsLoadingMore: true));

    try {
      final nextPage = state.promotionsPage + 1;
      final result = await retailerHomeRepository.getPromotedProducts(
        page: nextPage,
        size: _pageSize,
      );

      emit(
        state.copyWith(
          isPromotionsLoadingMore: false,
          promotedProducts: [...state.promotedProducts, ...result.content],
          promotionsPage: result.page,
          promotionsHasMore: result.hasNext,
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
          searchResults: const [],
          searchQuery: '',
          hasSearched: false,
          searchPage: 0,
          searchHasMore: true,
          clearError: true,
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSearchLoading: true,
        searchQuery: trimmedQuery,
        hasSearched: true,
        searchPage: 0,
        searchHasMore: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await retailerHomeRepository.searchProducts(
        trimmedQuery,
        page: 0,
        size: _pageSize,
      );

      // Ignore stale responses if the query changed while the request was in flight.
      if (state.searchQuery != trimmedQuery) return;

      emit(
        state.copyWith(
          isSearchLoading: false,
          searchResults: result.content,
          searchPage: result.page,
          searchHasMore: result.hasNext,
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

  Future<void> loadMoreSearchResults() async {
    if (state.isSearchLoadingMore ||
        !state.searchHasMore ||
        state.searchQuery.isEmpty) {
      return;
    }

    final currentQuery = state.searchQuery;
    emit(state.copyWith(isSearchLoadingMore: true));

    try {
      final nextPage = state.searchPage + 1;
      final result = await retailerHomeRepository.searchProducts(
        currentQuery,
        page: nextPage,
        size: _pageSize,
      );

      // Discard if the query changed while this page was loading.
      if (state.searchQuery != currentQuery) return;

      emit(
        state.copyWith(
          isSearchLoadingMore: false,
          searchResults: [...state.searchResults, ...result.content],
          searchPage: result.page,
          searchHasMore: result.hasNext,
        ),
      );
    } catch (e) {
      if (state.searchQuery != currentQuery) return;

      emit(
        state.copyWith(
          isSearchLoadingMore: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadBannerTargetProducts(HomeBannerModel banner) async {
    final targetType = banner.targetType.trim().toUpperCase();
    final targetValue = int.tryParse(banner.targetValue?.trim() ?? '');

    emit(
      state.copyWith(
        isBannerTargetLoading: true,
        bannerTargetProducts: const [],
        bannerTargetPage: 0,
        bannerTargetHasMore: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    if (targetValue == null || targetType.isEmpty || targetType == 'NONE') {
      emit(
        state.copyWith(
          isBannerTargetLoading: false,
          bannerTargetHasMore: false,
        ),
      );
      return;
    }

    try {
      if (targetType == 'PRODUCT') {
        final product = await retailerHomeRepository.getProductById(
          targetValue,
        );

        emit(
          state.copyWith(
            isBannerTargetLoading: false,
            bannerTargetProducts: [product],
            bannerTargetHasMore: false,
          ),
        );
        return;
      }

      final result = await retailerHomeRepository.getFeaturedProducts(
        page: 0,
        size: _pageSize,
        categoryId: targetType == 'CATEGORY' ? targetValue : null,
        subCategoryId: targetType == 'SUBCATEGORY' ? targetValue : null,
      );

      emit(
        state.copyWith(
          isBannerTargetLoading: false,
          bannerTargetProducts: result.content,
          bannerTargetPage: result.page,
          bannerTargetHasMore: result.hasNext,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isBannerTargetLoading: false,
          bannerTargetHasMore: false,
          errorMessage: AppErrorMapper.toMessage(e),
        ),
      );
    }
  }

  Future<void> loadMoreBannerTargetProducts(HomeBannerModel banner) async {
    if (state.isBannerTargetLoadingMore || !state.bannerTargetHasMore) return;

    final targetType = banner.targetType.trim().toUpperCase();
    final targetValue = int.tryParse(banner.targetValue?.trim() ?? '');
    if (targetValue == null || targetType == 'PRODUCT') return;

    emit(state.copyWith(isBannerTargetLoadingMore: true));

    try {
      final nextPage = state.bannerTargetPage + 1;
      final result = await retailerHomeRepository.getFeaturedProducts(
        page: nextPage,
        size: _pageSize,
        categoryId: targetType == 'CATEGORY' ? targetValue : null,
        subCategoryId: targetType == 'SUBCATEGORY' ? targetValue : null,
      );

      emit(
        state.copyWith(
          isBannerTargetLoadingMore: false,
          bannerTargetProducts: [
            ...state.bannerTargetProducts,
            ...result.content,
          ],
          bannerTargetPage: result.page,
          bannerTargetHasMore: result.hasNext,
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
}
