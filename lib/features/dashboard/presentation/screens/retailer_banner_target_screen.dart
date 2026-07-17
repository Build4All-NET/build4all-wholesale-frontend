import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../../data/models/retailer_home_model.dart';
import '../cubit/retailer_home_cubit.dart';
import '../cubit/retailer_home_state.dart';
import 'retailer_category_products_screen.dart';

class RetailerBannerTargetScreen extends StatelessWidget {
  final HomeBannerModel banner;

  const RetailerBannerTargetScreen({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerHomeCubit>()..loadBannerTargetProducts(banner),
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

class _RetailerBannerTargetViewState
    extends State<_RetailerBannerTargetView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<RetailerHomeCubit>().loadMoreBannerTargetProducts(
        widget.banner,
      );
    }
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
          if (state.isBannerTargetLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final products = state.bannerTargetProducts;

          if (products.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: products.length + (state.isBannerTargetLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= products.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                );
              }

              final product = products[index];

              return Padding(
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
              );
            },
          );
        },
      ),
    );
  }
}
