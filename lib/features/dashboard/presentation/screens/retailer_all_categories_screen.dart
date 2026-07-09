import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';
import '../widgets/retailer_promotion_badge.dart';

class RetailerAllCategoriesScreen extends StatefulWidget {
  final List<HomeCategoryModel> categories;

  const RetailerAllCategoriesScreen({
    super.key,
    required this.categories,
  });

  @override
  State<RetailerAllCategoriesScreen> createState() =>
      _RetailerAllCategoriesScreenState();
}

class _RetailerAllCategoriesScreenState
    extends State<RetailerAllCategoriesScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HomeCategoryModel> _activeCategories() {
    return widget.categories
        .where((category) => category.productCount > 0)
        .toList(growable: false);
  }

  List<HomeCategoryModel> _filteredCategories(List<HomeCategoryModel> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((category) {
      final text = [
        category.name,
        category.productCount.toString(),
        ...category.subCategories.map((subCategory) => subCategory.name),
      ].join(' ').toLowerCase();

      return text.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeCategories = _activeCategories();
    final visibleCategories = _filteredCategories(activeCategories);
    final hasQuery = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: Text(
          l10n.categories,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: activeCategories.isEmpty
          ? Center(
              child: Text(
                l10n.noProductsInCategory,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: _SearchBox(
                      controller: _searchController,
                      hintText: l10n.searchCategoriesHint,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                ),
                if (visibleCategories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptySearchState(
                      message: hasQuery
                          ? l10n.noProductsInCategory
                          : l10n.noProductsInCategory,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid.builder(
                      itemCount: visibleCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.25,
                      ),
                      itemBuilder: (context, index) {
                        final category = visibleCategories[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            context.push(
                              '/retailer-category-products',
                              extra: category,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppThemeTokens.surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppThemeTokens.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.035),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 96,
                                        height: 48,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            Text(
                                              category.icon,
                                              style:
                                                  const TextStyle(fontSize: 34),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 6,
                                              child:
                                                  RetailerCategoryPromotionBadge(
                                                category: category,
                                                maxWidth: 66,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                fontSize: 8.5,
                                                iconSize: 9.5,
                                                gap: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        category.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppThemeTokens.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          height: 1.15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${category.productCount} ${l10n.productsLabel}',
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                hintText: hintText,
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

class _EmptySearchState extends StatelessWidget {
  final String message;

  const _EmptySearchState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 58,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
