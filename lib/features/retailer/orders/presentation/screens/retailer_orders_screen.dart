import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/retailer_order_entity.dart';
import '../cubit/retailer_orders_cubit.dart';
import '../cubit/retailer_orders_state.dart';
import '../utils/retailer_order_i18n.dart';
import '../widgets/retailer_order_card.dart';

class RetailerOrdersScreen extends StatelessWidget {
  const RetailerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerOrdersCubit>()..loadOrders(),
      child: const _RetailerOrdersView(),
    );
  }
}

class _RetailerOrdersView extends StatefulWidget {
  const _RetailerOrdersView();

  @override
  State<_RetailerOrdersView> createState() => _RetailerOrdersViewState();
}

class _RetailerOrdersViewState extends State<_RetailerOrdersView> {
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

  List<RetailerOrderEntity> _searchOrders(List<RetailerOrderEntity> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((order) {
      final itemNames = order.items.map((item) => item.productName).join(' ');
      final text = [
        order.orderNumber,
        order.status.name,
        order.paymentMethod,
        order.deliveryAddress,
        order.branchName ?? '',
        order.branchCity ?? '',
        order.branchAddress ?? '',
        order.totalAmount.toStringAsFixed(2),
        order.totalItems.toString(),
        itemNames,
      ].join(' ').toLowerCase();

      return text.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: Text(
          i18n.myOrders,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: BlocConsumer<RetailerOrdersCubit, RetailerOrdersState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            AppToast.error(context, state.errorMessage!);
            context.read<RetailerOrdersCubit>().clearMessages();
          }

          if (state.successMessage == 'ORDER_CANCELLED') {
            AppToast.success(context, i18n.orderCancelled);
            context.read<RetailerOrdersCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.orders.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final filteredByStatus = state.filteredOrders;
          final visibleOrders = _searchOrders(filteredByStatus);
          final hasSearch = _searchQuery.trim().isNotEmpty;

          return RefreshIndicator(
            onRefresh: () => context.read<RetailerOrdersCubit>().refreshOrders(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: _OrderSearchBox(
                      controller: _searchController,
                      hintText: context.l10n.searchOrdersHint,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _OrderFilterTabs(state: state),
                  ),
                ),
                if (state.orders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyOrdersState(
                      title: i18n.noOrdersTitle,
                      message: i18n.noOrdersMessage,
                    ),
                  )
                else if (filteredByStatus.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyOrdersState(
                      title: i18n.noOrdersTitle,
                      message: i18n.noFilteredOrders,
                    ),
                  )
                else if (visibleOrders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyOrdersState(
                      title: i18n.noOrdersTitle,
                      message: i18n.noFilteredOrders,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: visibleOrders.length,
                      itemBuilder: (context, index) {
                        final order = visibleOrders[index];

                        return RetailerOrderCard(
                          order: order,
                          onTrack: () => context.push(
                            '/retailer-orders/${order.id}',
                          ),
                          onCancel: order.canCancel
                              ? () => _confirmCancel(context, order)
                              : null,
                          onReorder: order.canReorder
                              ? () => context.push(
                                    '/retailer-orders/${order.id}/reorder',
                                  )
                              : null,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    RetailerOrderEntity order,
  ) async {
    final i18n = RetailerOrderI18n(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(i18n.cancelOrderTitle),
          content: Text(i18n.cancelOrderMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(i18n.keepOrder),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(i18n.cancelOrder),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<RetailerOrdersCubit>().cancelOrder(orderId: order.id);
    }
  }
}

class _OrderSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _OrderSearchBox({
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

class _OrderFilterTabs extends StatelessWidget {
  final RetailerOrdersState state;

  const _OrderFilterTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);
    final filters = RetailerOrderFilter.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = state.selectedFilter == filter;
          final count = state.countForFilter(filter);

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: ChoiceChip(
              selected: selected,
              label: Text('${i18n.filterLabel(filter)} ($count)'),
              onSelected: (_) {
                context.read<RetailerOrdersCubit>().selectFilter(filter);
              },
              selectedColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
              backgroundColor: AppThemeTokens.surface,
              side: BorderSide(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : AppThemeTokens.border,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyOrdersState({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
