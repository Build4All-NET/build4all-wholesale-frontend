import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/widgets/quantity_input_dialog.dart';
import '../../../../injection_container.dart';
import '../../../retailer/product_ai/presentation/widgets/retailer_product_ai_button.dart';
import '../../data/models/retailer_home_model.dart';
import '../cubit/retailer_home_cubit.dart';
import '../cubit/retailer_home_state.dart';
import '../widgets/retailer_product_image.dart';
import '../widgets/retailer_promotion_badge.dart';

class RetailerProductDetailsScreen extends StatelessWidget {
  final HomeProductModel product;

  const RetailerProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerHomeCubit>(),
      child: _RetailerProductDetailsView(product: product),
    );
  }
}

class _RetailerProductDetailsView extends StatefulWidget {
  final HomeProductModel product;

  const _RetailerProductDetailsView({required this.product});

  @override
  State<_RetailerProductDetailsView> createState() =>
      _RetailerProductDetailsViewState();
}

class _RetailerProductDetailsViewState
    extends State<_RetailerProductDetailsView> {
  late int _quantity;

  int get _safeMoq => widget.product.moq <= 0 ? 1 : widget.product.moq;

  @override
  void initState() {
    super.initState();
    _quantity = _safeMoq;
  }

  void _increaseQuantity() {
    setState(() => _quantity += 1);
  }

  void _decreaseQuantity() {
    final nextQuantity = _quantity - 1;
    if (nextQuantity < _safeMoq) return;

    setState(() => _quantity = nextQuantity);
  }

  Future<void> _editQuantity() async {
    final newQuantity = await showQuantityInputDialog(
      context,
      initialQuantity: _quantity,
      minQuantity: _safeMoq,
      unitLabel: widget.product.moqUnit,
    );

    if (newQuantity == null || !mounted) return;

    setState(() => _quantity = newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final l10n = context.l10n;
    final isOutOfStock = product.totalStock <= 0;

    return BlocConsumer<RetailerHomeCubit, RetailerHomeState>(
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
        final isAdding = state.addingProductId == product.id;

        return Scaffold(
          backgroundColor: AppThemeTokens.background,
          appBar: AppBar(
            backgroundColor: AppThemeTokens.background,
            elevation: 0,
            title: Text(
              l10n.productDetails,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _ProductImageHeader(product: product),
              const SizedBox(height: 16),
              _ProductMainInfo(product: product),
              const SizedBox(height: 14),
              _DescriptionCard(product: product),
              const SizedBox(height: 14),
              _QuantityCard(
                product: product,
                quantity: _quantity,
                onIncrease: isOutOfStock ? null : _increaseQuantity,
                onDecrease: isOutOfStock || _quantity <= _safeMoq
                    ? null
                    : _decreaseQuantity,
                onEdit: isOutOfStock ? null : _editQuantity,
              ),
              _LockedPromotionExplanation(product: product),
              const SizedBox(height: 14),
              RetailerProductAiButton(
                productId: product.id,
                productName: product.name,
                imageUrl: product.imageUrl,
                expanded: true,
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: AppThemeTokens.surface,
                border: Border(
                  top: BorderSide(color: AppThemeTokens.border),
                ),
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isAdding || isOutOfStock
                      ? null
                      : () {
                          context.read<RetailerHomeCubit>().addToCart(
                            product: product,
                            quantity: _quantity,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppThemeTokens.border,
                    disabledForegroundColor: AppThemeTokens.textSecondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isAdding
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isOutOfStock ? l10n.outOfStock : l10n.addToCart,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductImageHeader extends StatelessWidget {
  final HomeProductModel product;

  const _ProductImageHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RetailerProductImage(
          imageUrl: product.imageUrl,
          width: double.infinity,
          height: 250,
          borderRadius: 28,
          iconSize: 64,
          imagePadding: const EdgeInsets.all(12),
        ),
        if (product.hasActivePromotion)
          Positioned(
            top: 14,
            left: 14,
            child: RetailerPromotionBadge(product: product),
          ),
      ],
    );
  }
}

class _ProductMainInfo extends StatelessWidget {
  final HomeProductModel product;

  const _ProductMainInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    final categoryLine = _categoryLine(product);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categoryLine.isNotEmpty) ...[
            Text(
              categoryLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
          ],
          Text(
            product.name,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1.14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: Text(
                  _formatMoney(product.currency, product.price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (product.shouldShowOriginalPrice) ...[
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    _formatMoney(product.currency, product.originalPrice!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.lineThrough,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _SmallInfoPill(
            icon: Icons.inventory_2_outlined,
            text: '${l10n.minimumOrder}: ${product.moq} ${product.moqUnit}',
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

class _DescriptionCard extends StatelessWidget {
  final HomeProductModel product;

  const _DescriptionCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final description = product.description.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.description,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty
                ? context.l10n.noDescriptionAvailable
                : description,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  final HomeProductModel product;
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onEdit;

  const _QuantityCard({
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quantity,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.moq}: ${product.moq} ${product.moqUnit}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _QuantityButton(
            icon: Icons.remove_rounded,
            onTap: onDecrease,
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onEdit,
            child: SizedBox(
              width: 66,
              height: 38,
              child: Center(
                child: Text(
                  quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : AppThemeTokens.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.22)
                : AppThemeTokens.border,
          ),
        ),
        child: Icon(
          icon,
          color: enabled
              ? Theme.of(context).colorScheme.primary
              : AppThemeTokens.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

class _LockedPromotionExplanation extends StatelessWidget {
  final HomeProductModel product;

  const _LockedPromotionExplanation({required this.product});

  @override
  Widget build(BuildContext context) {
    final explanation = _buildExplanation(context);
    if (explanation == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_offer_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    explanation.title,
                    style: const TextStyle(
                      color: AppThemeTokens.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...explanation.lines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  if (explanation.footer != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      explanation.footer!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PromotionExplanationData? _buildExplanation(BuildContext context) {
    final tiers = _promotionTiers(context);
    final l10n = context.l10n;

    if (tiers.length > 1) {
      return _PromotionExplanationData(
        title: l10n.promotionTiersAvailable,
        lines: tiers.map((tier) => _buildTierLine(context, tier)).toList(),
        footer: l10n.bestEligiblePromotionAppliedAtCheckout,
      );
    }

    if (tiers.length == 1) {
      if (product.shouldShowOriginalPrice) return null;

      final tier = tiers.first;
      final line = _buildTierLine(context, tier);
      final shouldAddUnlockNote =
          (tier.promotionMinimumOrderAmount ?? 0) > 0 &&
          !product.shouldShowOriginalPrice;

      return _PromotionExplanationData(
        title: l10n.promotionAvailable,
        lines: [
          shouldAddUnlockNote
              ? '$line ${l10n.increaseQuantityInCartToUnlockPromotion}'
              : line,
        ],
      );
    }

    final fallback = _buildSingleFallbackMessage(context);
    if (fallback == null) return null;

    return _PromotionExplanationData(
      title: l10n.promotionAvailable,
      lines: [fallback],
    );
  }

  List<PromotionTierModel> _promotionTiers(BuildContext context) {
    final seenIds = <int>{};
    final tiers = product.promotionTiers.where((tier) {
      final label = _tierLabel(context, tier).trim();
      if (label.isEmpty) return false;

      final id = tier.promotionId;
      if (id != null && !seenIds.add(id)) return false;

      return true;
    }).toList();

    tiers.sort((a, b) {
      final minCompare = (a.promotionMinimumOrderAmount ?? 0)
          .compareTo(b.promotionMinimumOrderAmount ?? 0);
      if (minCompare != 0) return minCompare;

      return (a.promotionId ?? 0).compareTo(b.promotionId ?? 0);
    });

    return tiers;
  }

  String? _buildSingleFallbackMessage(BuildContext context) {
    if (!product.hasActivePromotion || product.shouldShowOriginalPrice) {
      return null;
    }

    final label = product.promotionLabel?.trim();
    if (label == null || label.isEmpty) return null;

    final l10n = context.l10n;
    final minimum = product.promotionMinimumOrderAmount;
    final maximum = product.promotionMaximumDiscountAmount;
    final buffer = StringBuffer(label);

    if (minimum != null && minimum > 0) {
      buffer.write(
        ' ${l10n.availableFrom} ${_formatMoney(product.currency, minimum)}',
      );
    }

    if (maximum != null && maximum > 0) {
      buffer.write(
        '. ${l10n.maximumDiscount}: ${_formatMoney(product.currency, maximum)}',
      );
    }

    if (minimum != null && minimum > 0) {
      buffer.write('. ${l10n.increaseQuantityInCartToUnlockPromotion}');
    }

    final message = buffer.toString().trim();
    if (message.isEmpty) return null;

    return message.endsWith('.') ? message : '$message.';
  }

  String _buildTierLine(BuildContext context, PromotionTierModel tier) {
    final l10n = context.l10n;
    final label = _tierLabel(context, tier);
    final minimum = tier.promotionMinimumOrderAmount;
    final maximum = tier.promotionMaximumDiscountAmount;
    final buffer = StringBuffer(label);

    if (minimum != null && minimum > 0) {
      buffer.write(
        ' ${l10n.availableFrom} ${_formatMoney(product.currency, minimum)}',
      );
    }

    if (maximum != null && maximum > 0) {
      buffer.write(
        ', ${l10n.maximumDiscount.toLowerCase()}: ${_formatMoney(product.currency, maximum)}',
      );
    }

    final line = buffer.toString().trim();
    if (line.endsWith('.')) return line;
    return '$line.';
  }

  String _tierLabel(BuildContext context, PromotionTierModel tier) {
    final label = tier.promotionLabel?.trim();
    if (label != null && label.isNotEmpty) {
      if (tier.promotionDiscountType?.toUpperCase() == 'FIXED') {
        return '$label ${context.l10n.perUnit}';
      }
      return label;
    }

    final value = tier.promotionDiscountValue;
    if (value == null || value <= 0) return '';

    if (tier.promotionDiscountType?.toUpperCase() == 'PERCENT') {
      return '${_formatNumber(value)}% OFF';
    }

    if (tier.promotionDiscountType?.toUpperCase() == 'FIXED') {
      return '${_formatMoney(product.currency, value)} OFF ${context.l10n.perUnit}';
    }

    return '';
  }

}

class _PromotionExplanationData {
  final String title;
  final List<String> lines;
  final String? footer;

  const _PromotionExplanationData({
    required this.title,
    required this.lines,
    this.footer,
  });
}

class _SmallInfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallInfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppThemeTokens.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatNumber(double value) {
  return value.truncateToDouble() == value
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String _formatMoney(String currency, double value) {
  final formatted = value.truncateToDouble() == value
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  return '$currency$formatted';
}
