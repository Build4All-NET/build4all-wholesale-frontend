import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../../data/models/retailer_home_model.dart';
import '../cubit/retailer_home_cubit.dart';
import '../cubit/retailer_home_state.dart';
import '../widgets/retailer_pagination_footer.dart';
import 'retailer_category_products_screen.dart';

class RetailerBannerTargetScreen extends StatelessWidget {
  final HomeBannerModel banner;
  const RetailerBannerTargetScreen({
    super.key,
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<RetailerHomeCubit>()..loadBannerTargetProducts(banner: banner),
      child: _RetailerBannerTargetView(banner: banner),
    );
  }
}

class _RetailerBannerTargetView extends StatefulWidget {
  final HomeBannerModel banner;

  const _RetailerBannerTargetView({required this.banner});

  @override
  State<_RetailerBannerTargetView> createState() =>
      _RetailerBannerTargetViewState();
}

class _RetailerBannerTargetViewState extends State<_RetailerBannerTargetView> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
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
      context.read<RetailerHomeCubit>().loadMoreBannerTargetProducts();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<RetailerHomeCubit>().loadBannerTargetProducts(
        banner: widget.banner,
        search: value,
      );
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
        title: Text(
          widget.banner.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: BlocConsumer<RetailerHomeCubit, RetailerHomeState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            AppToast.error(context, state.errorMessage!);
            context.read<RetailerHomeCubit>().clearMessages();
          }

          if (state.successMessage == 'PRODUCT_ADDED_TO_CART') {
            AppToast.success(context, l10n.productAddedToCart);
            context.read<RetailerHomeCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.isBannerTargetLoading && state.bannerTargetProducts.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final products = state.bannerTargetProducts;

          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () => context
                .read<RetailerHomeCubit>()
                .loadBannerTargetProducts(
                  banner: widget.banner,
                  search: _searchController.text,
                ),
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _SearchBox(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 14),
                if (products.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.noProductsInCategory,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
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
                  isLoadingMore: state.isBannerTargetLoadingMore,
                  hasNext: state.bannerTargetHasNext,
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
