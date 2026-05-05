import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../../data/models/retailer_home_model.dart';
import '../cubit/retailer_home_cubit.dart';
import '../cubit/retailer_home_state.dart';

class RetailerCategoryProductsScreen extends StatelessWidget {
  final HomeCategoryModel category;

  const RetailerCategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<RetailerHomeCubit>()..loadProductsByCategory(category: category),
      child: _RetailerCategoryProductsView(category: category),
    );
  }
}

class _RetailerCategoryProductsView extends StatefulWidget {
  final HomeCategoryModel category;

  const _RetailerCategoryProductsView({required this.category});

  @override
  State<_RetailerCategoryProductsView> createState() =>
      _RetailerCategoryProductsViewState();
}

class _RetailerCategoryProductsViewState
    extends State<_RetailerCategoryProductsView> {
  late final TextEditingController _searchController;

  String _query = '';
  String? _selectedSubCategoryName;

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

  List<String> _extractSubCategories(List<HomeProductModel> products) {
    final subCategories = products
        .map((product) => product.subCategoryName?.trim())
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    subCategories.sort();
    return subCategories;
  }

  List<HomeProductModel> _filterProducts(List<HomeProductModel> products) {
    final cleanQuery = _query.trim().toLowerCase();

    return products.where((product) {
      final matchesSubCategory =
          _selectedSubCategoryName == null ||
          product.subCategoryName == _selectedSubCategoryName;

      final searchableText = [
        product.name,
        product.description,
        product.categoryName ?? '',
        product.subCategoryName ?? '',
      ].join(' ').toLowerCase();

      final matchesSearch =
          cleanQuery.isEmpty || searchableText.contains(cleanQuery);

      return matchesSubCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        titleSpacing: 0,
        title: BlocBuilder<RetailerHomeCubit, RetailerHomeState>(
          builder: (context, state) {
            final filteredProducts = _filterProducts(state.categoryProducts);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${filteredProducts.length} ${l10n.productsLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: BlocConsumer<RetailerHomeCubit, RetailerHomeState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<RetailerHomeCubit>().clearMessages();
          }

          if (state.successMessage == 'PRODUCT_ADDED_TO_CART') {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.productAddedToCart)));
            context.read<RetailerHomeCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.isCategoryProductsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final subCategories = _extractSubCategories(state.categoryProducts);
          final filteredProducts = _filterProducts(state.categoryProducts);

          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () => context
                .read<RetailerHomeCubit>()
                .loadProductsByCategory(category: widget.category),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SearchBox(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _query = value);
                  },
                ),
                const SizedBox(height: 12),
                _SubCategoryChips(
                  subCategories: subCategories,
                  selectedSubCategoryName: _selectedSubCategoryName,
                  onSelected: (name) {
                    setState(() => _selectedSubCategoryName = name);
                  },
                ),
                const SizedBox(height: 16),
                if (filteredProducts.isEmpty)
                  _EmptyProductsState(categoryName: widget.category.name)
                else
                  ...filteredProducts.map(
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
          if (controller.text.isNotEmpty)
            IconButton(
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
            ),
        ],
      ),
    );
  }
}

class _SubCategoryChips extends StatelessWidget {
  final List<String> subCategories;
  final String? selectedSubCategoryName;
  final ValueChanged<String?> onSelected;

  const _SubCategoryChips({
    required this.subCategories,
    required this.selectedSubCategoryName,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subCategories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Chip(
              label: l10n.all,
              selected: selectedSubCategoryName == null,
              color: primary,
              onTap: () => onSelected(null),
            );
          }

          final subCategory = subCategories[index - 1];

          return _Chip(
            label: subCategory,
            selected: selectedSubCategoryName == subCategory,
            color: primary,
            onTap: () => onSelected(subCategory),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 36,
        constraints: const BoxConstraints(maxWidth: 170),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? color : AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? color : AppThemeTokens.border),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : AppThemeTokens.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class RetailerProductListCard extends StatelessWidget {
  final HomeProductModel product;
  final bool isAdding;
  final VoidCallback onAdd;

  const RetailerProductListCard({
    super.key,
    required this.product,
    required this.isAdding,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    final isOutOfStock = product.totalStock <= 0;

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(imageUrl: product.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                if (product.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${product.currency}${product.price.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniInfo(
                      icon: Icons.inventory_2_outlined,
                      text: '${l10n.moq}: ${product.moq} ${product.moqUnit}',
                    ),
                    _MiniInfo(
                      icon: Icons.warehouse_outlined,
                      text: '${l10n.stock}: ${product.totalStock}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _AddButton(
                      isAdding: isAdding,
                      disabled: isOutOfStock,
                      onPressed: onAdd,
                    ),
                  ),
                ),
              ],
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
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = imageUrl?.trim();

    return Container(
      width: 86,
      height: 96,
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanImageUrl == null || cleanImageUrl.isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              color: AppThemeTokens.textSecondary,
              size: 34,
            )
          : Image.network(
              cleanImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.inventory_2_outlined,
                  color: AppThemeTokens.textSecondary,
                  size: 34,
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
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppThemeTokens.textSecondary),
          const SizedBox(width: 4),
          Flexible(
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

class _AddButton extends StatelessWidget {
  final bool isAdding;
  final bool disabled;
  final VoidCallback onPressed;

  const _AddButton({
    required this.isAdding,
    required this.disabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: disabled ? 132 : 104,
      height: 38,
      child: ElevatedButton(
        onPressed: isAdding || disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: AppThemeTokens.border,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppThemeTokens.textSecondary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isAdding
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!disabled) ...[
                    const Icon(Icons.add_rounded, size: 17),
                    const SizedBox(width: 3),
                  ],
                  Flexible(
                    child: Text(
                      disabled ? l10n.outOfStock : l10n.add,
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
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  final String categoryName;

  const _EmptyProductsState({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.noProductsInCategory,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            categoryName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
