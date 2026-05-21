import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';

class RetailerPromotionBadge extends StatelessWidget {
  final HomeProductModel product;
  final EdgeInsets padding;
  final double fontSize;

  const RetailerPromotionBadge({
    super.key,
    required this.product,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final label = product.promotionLabel?.trim();

    if (!product.hasActivePromotion || label == null || label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 118),
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.05,
        ),
      ),
    );
  }
}

class RetailerCategoryPromotionBadge extends StatelessWidget {
  final HomeCategoryModel category;
  final double maxWidth;
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
  final double gap;

  const RetailerCategoryPromotionBadge({
    super.key,
    required this.category,
    this.maxWidth = 96,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    this.fontSize = 9,
    this.iconSize = 11,
    this.gap = 3,
  });

  @override
  Widget build(BuildContext context) {
    final label = category.promotionLabel?.trim();

    if (!category.hasActivePromotion || label == null || label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_rounded,
            size: iconSize,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: gap),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RetailerPromotionInfoPill extends StatelessWidget {
  final HomeProductModel product;

  const RetailerPromotionInfoPill({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final label = product.promotionLabel?.trim();
    final title = product.promotionTitle?.trim();

    if (!product.hasActivePromotion || label == null || label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title == null || title.isEmpty ? label : '$label • $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
