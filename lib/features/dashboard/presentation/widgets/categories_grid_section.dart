import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';

class CategoriesGridSection extends StatelessWidget {
  final List<HomeCategoryModel> categories;

  const CategoriesGridSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        _SectionHeader(
          title: l10n.categories,
          actionText: l10n.seeAll,
          onTap: () => context.push('/retailer-categories', extra: categories),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: categories.length > 6 ? 6 : categories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            return _CategoryTile(category: categories[index]);
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

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/retailer-category-products', extra: category),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          border: Border.all(color: AppThemeTokens.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category.productCount} ${l10n.productsLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
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
  final String actionText;
  final VoidCallback onTap;

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
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionText,
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
