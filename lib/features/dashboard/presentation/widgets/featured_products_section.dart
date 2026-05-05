import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';

class FeaturedProductsSection extends StatelessWidget {
  final List<HomeProductModel> products;

  /// Only the clicked product id becomes loading.
  final int? addingProductId;

  final void Function(HomeProductModel product) onAddToCart;

  const FeaturedProductsSection({
    super.key,
    required this.products,
    required this.addingProductId,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.featuredProducts,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: null,
              child: Text(
                l10n.viewAll,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 380,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final product = products[index];

              return _ProductCard(
                product: product,
                isAddingThisProduct: addingProductId == product.id,
                onAddToCart: onAddToCart,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final HomeProductModel product;

  /// Only true for the clicked product.
  final bool isAddingThisProduct;

  final void Function(HomeProductModel product) onAddToCart;

  const _ProductCard({
    required this.product,
    required this.isAddingThisProduct,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isOutOfStock = product.totalStock <= 0;

    return Container(
      width: 224,
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        border: Border.all(color: AppThemeTokens.border),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(product: product),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.badgeLabel != null &&
                      product.badgeLabel!.trim().isNotEmpty) ...[
                    _Badge(product: product),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.18,
                    ),
                  ),
                  if (product.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppThemeTokens.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _categoryLine(product),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.currency}${product.price.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MiniInfo(
                    icon: Icons.inventory_2_outlined,
                    text: '${l10n.moq}: ${product.moq} ${product.moqUnit}',
                  ),
                  const SizedBox(height: 6),
                  _MiniInfo(
                    icon: Icons.warehouse_outlined,
                    text: '${l10n.stock}: ${product.totalStock}',
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      /// Only clicked product is disabled/loading.
                      /// Other product buttons stay normal.
                      onPressed: isAddingThisProduct || isOutOfStock
                          ? null
                          : () => onAddToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppThemeTokens.border,
                        disabledForegroundColor: AppThemeTokens.textSecondary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isAddingThisProduct
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!isOutOfStock) ...[
                                  const Icon(Icons.add_rounded, size: 18),
                                  const SizedBox(width: 4),
                                ],
                                Flexible(
                                  child: Text(
                                    isOutOfStock ? l10n.outOfStock : l10n.add,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLine(HomeProductModel product) {
    final category = product.categoryName ?? '';
    final subCategory = product.subCategoryName ?? '';

    if (category.isNotEmpty && subCategory.isNotEmpty) {
      return '$category • $subCategory';
    }

    if (category.isNotEmpty) return category;
    if (subCategory.isNotEmpty) return subCategory;

    return '';
  }
}

class _ProductImage extends StatelessWidget {
  final HomeProductModel product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;

    return Container(
      height: 108,
      width: double.infinity,
      color: AppThemeTokens.background,
      child: imageUrl == null || imageUrl.trim().isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              size: 46,
              color: AppThemeTokens.textSecondary,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.inventory_2_outlined,
                  size: 46,
                  color: AppThemeTokens.textSecondary,
                );
              },
            ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppThemeTokens.textSecondary),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final HomeProductModel product;

  const _Badge({required this.product});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(product.badgeColor ?? '#EF4444');

    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        product.badgeLabel!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return Color(value ?? 0xFFEF4444);
  }
}
