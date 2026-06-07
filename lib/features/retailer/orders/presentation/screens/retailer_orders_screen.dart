import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

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

class _RetailerOrdersView extends StatelessWidget {
  const _RetailerOrdersView();

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

          return RefreshIndicator(
            onRefresh: () => context.read<RetailerOrdersCubit>().refreshOrders(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
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
                else if (state.filteredOrders.isEmpty)
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
                      itemCount: state.filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = state.filteredOrders[index];

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
