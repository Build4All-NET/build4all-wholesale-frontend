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
  final List<HomeProductModel> products;

  const RetailerBannerTargetScreen({
    super.key,
    required this.banner,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerHomeCubit>(),
      child: _RetailerBannerTargetView(
        banner: banner,
        products: _filterProductsByBannerTarget(banner, products),
      ),
    );
  }

  List<HomeProductModel> _filterProductsByBannerTarget(
    HomeBannerModel banner,
    List<HomeProductModel> products,
  ) {
    final targetType = banner.targetType.trim().toUpperCase();

    if (targetType.isEmpty || targetType == 'NONE') {
      return const [];
    }

    final targetValue = int.tryParse(banner.targetValue?.trim() ?? '');

    if (targetValue == null) {
      return const [];
    }

    switch (targetType) {
      case 'PRODUCT':
        return products.where((product) => product.id == targetValue).toList();

      case 'CATEGORY':
        return products
            .where((product) => product.categoryId == targetValue)
            .toList();

      case 'SUBCATEGORY':
        return products
            .where((product) => product.subCategoryId == targetValue)
            .toList();

      default:
        return const [];
    }
  }
}

class _RetailerBannerTargetView extends StatelessWidget {
  final HomeBannerModel banner;
  final List<HomeProductModel> products;

  const _RetailerBannerTargetView({
    required this.banner,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: Text(
          banner.title,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: products.length,
            itemBuilder: (context, index) {
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
