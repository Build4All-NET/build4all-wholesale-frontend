import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';

class CategoriesGridSection extends StatelessWidget {
  static const int _dashboardCategoryLimit = 6;

  final List<HomeCategoryModel> categories;

  const CategoriesGridSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final activeCategories = categories
        .where((category) => category.productCount > 0)
        .toList(growable: false);

    if (activeCategories.isEmpty) return const SizedBox.shrink();

    final visibleCategories = activeCategories
        .take(_dashboardCategoryLimit)
        .toList(growable: false);
    final hasMoreCategories = activeCategories.length > _dashboardCategoryLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.categories,
          actionText: hasMoreCategories
              ? '${l10n.seeAll} (${activeCategories.length})'
              : null,
          onTap: hasMoreCategories
              ? () => context.push(
                    '/retailer-categories',
                    extra: activeCategories,
                  )
              : null,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: visibleCategories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            return _CategoryTile(category: visibleCategories[index]);
          },
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final HomeCategoryModel category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final promotionLabel = category.promotionLabel?.trim() ?? '';
    final hasPromotion =
        category.hasActivePromotion && promotionLabel.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/retailer-category-products', extra: category),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppThemeTokens.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPromotion) ...[
              _PromotionBadge(label: promotionLabel),
              const SizedBox(height: 6),
            ],
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  category.name,
                  maxLines: hasPromotion ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 14, color: primaryColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${category.productCount} ${l10n.productsLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: 20,
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionBadge extends StatelessWidget {
  final String label;

  const _PromotionBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 138),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_outlined, size: 11, color: primaryColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionText != null && onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              actionText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}
