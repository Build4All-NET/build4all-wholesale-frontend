import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';

class FeaturedProductsSection extends StatelessWidget {
  final List<HomeProductModel> products;
  final bool isAddingToCart;
  final void Function(HomeProductModel product) onAddToCart;

  const FeaturedProductsSection({
    super.key,
    required this.products,
    required this.isAddingToCart,
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
                style: const TextStyle(
                  color: AppThemeTokens.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/retailer-promotions'),
              child: Text(
                l10n.viewAll,
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
          height: 292,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return _ProductCard(
                product: products[index],
                isAddingToCart: isAddingToCart,
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
  final bool isAddingToCart;
  final void Function(HomeProductModel product) onAddToCart;

  const _ProductCard({
    required this.product,
    required this.isAddingToCart,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.push('/retailer-promotions'),
      child: Container(
        width: 206,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppThemeTokens.border),
          borderRadius: BorderRadius.circular(22),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(product: product),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.badgeLabel != null &&
                      product.badgeLabel!.trim().isNotEmpty)
                    _Badge(product: product),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${product.currency}${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'MOQ: ${product.moq} ${product.moqUnit}',
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: isAddingToCart
                          ? null
                          : () => onAddToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isAddingToCart
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.add,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final HomeProductModel product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;

    return Container(
      height: 92,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: imageUrl == null || imageUrl.trim().isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              size: 42,
              color: AppThemeTokens.textSecondary,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.inventory_2_outlined,
                  size: 42,
                  color: AppThemeTokens.textSecondary,
                );
              },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        product.badgeLabel!,
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
