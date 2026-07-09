import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../cubit/retailer_home_cubit.dart';
import '../cubit/retailer_home_state.dart';
import '../widgets/retailer_pagination_footer.dart';
import 'retailer_category_products_screen.dart';

class RetailerFeaturedProductsScreen extends StatelessWidget {
  const RetailerFeaturedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerHomeCubit>()..loadAllProducts(),
      child: const _RetailerFeaturedProductsView(),
    );
  }
}

class _RetailerFeaturedProductsView extends StatefulWidget {
  const _RetailerFeaturedProductsView();

  @override
  State<_RetailerFeaturedProductsView> createState() =>
      _RetailerFeaturedProductsViewState();
}

class _RetailerFeaturedProductsViewState
    extends State<_RetailerFeaturedProductsView> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      context.read<RetailerHomeCubit>().loadMoreAllProducts();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<RetailerHomeCubit>().loadAllProducts(search: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          l10n.featuredProducts,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<RetailerHomeCubit, RetailerHomeState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            AppToast.error(context, state.errorMessage!);
            context.read<RetailerHomeCubit>().clearMessages();
            return;
          }

          if (state.successMessage == 'PRODUCT_ADDED_TO_CART') {
            AppToast.success(context, l10n.productAddedToCart);
            context.read<RetailerHomeCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.isAllProductsLoading && state.allProducts.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final products = state.allProducts;

          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () => context.read<RetailerHomeCubit>().loadAllProducts(
              search: _searchController.text,
            ),
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SearchBox(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 14),
                Text(
                  '${products.length} ${l10n.productsLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                if (products.isEmpty)
                  const _EmptyFeaturedProductsState()
                else
                  ...products.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RetailerProductListCard(
                        product: product,
                        isAdding: state.addingProductId == product.id,
                        onAdd: () {
                          context.read<RetailerHomeCubit>().addToCart(
                            product: product,
                          );
                        },
                      ),
                    ),
                  ),
                RetailerPaginationFooter(
                  isLoadingMore: state.isAllProductsLoadingMore,
                  hasNext: state.allProductsHasNext,
                  showEndMessage: products.length > 20,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppThemeTokens.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: l10n.searchProducts,
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();

              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppThemeTokens.textSecondary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyFeaturedProductsState extends StatelessWidget {
  const _EmptyFeaturedProductsState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.featuredProducts,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.checkConnectionTryAgain,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
