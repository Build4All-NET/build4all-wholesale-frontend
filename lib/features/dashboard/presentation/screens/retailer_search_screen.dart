import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../injection_container.dart';
import '../cubit/retailer_home_cubit.dart';
import '../cubit/retailer_home_state.dart';
import 'retailer_category_products_screen.dart';

class RetailerSearchScreen extends StatelessWidget {
  const RetailerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerHomeCubit>(),
      child: const _RetailerSearchView(),
    );
  }
}

class _RetailerSearchView extends StatefulWidget {
  const _RetailerSearchView();

  @override
  State<_RetailerSearchView> createState() => _RetailerSearchViewState();
}

class _RetailerSearchViewState extends State<_RetailerSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Open the keyboard immediately so the retailer can start typing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<RetailerHomeCubit>().searchProducts(query: value);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    context.read<RetailerHomeCubit>().searchProducts(query: '');
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
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _SearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
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
          if (state.isSearchLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (!state.hasSearched) {
            return _SearchHint(message: l10n.searchProducts);
          }

          if (state.searchResults.isEmpty) {
            return _EmptyResults(query: state.searchQuery);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final product = state.searchResults[index];

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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppThemeTokens.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
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
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();

              return IconButton(
                onPressed: onClear,
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

class _SearchHint extends StatelessWidget {
  final String message;

  const _SearchHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;

  const _EmptyResults({required this.query});

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
            l10n.noProductsFound,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (query.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '"$query"',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
