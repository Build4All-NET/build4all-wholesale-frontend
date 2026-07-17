import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../../dashboard/presentation/widgets/retailer_product_image.dart';
import '../../../cart/data/services/retailer_cart_service.dart';
import '../../domain/entities/retailer_order_entity.dart';
import '../../domain/entities/retailer_order_item_entity.dart';
import '../../domain/entities/skipped_reorder_item_entity.dart';
import '../cubit/retailer_orders_cubit.dart';
import '../cubit/retailer_orders_state.dart';
import '../utils/retailer_order_formatters.dart';
import '../utils/retailer_order_i18n.dart';
import '../widgets/retailer_order_status_chip.dart';

enum _ReorderCartChoice { add, replace }

class RetailerReorderReviewScreen extends StatelessWidget {
  final int orderId;

  const RetailerReorderReviewScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerOrdersCubit>()..loadOrderDetails(orderId: orderId),
      child: const _RetailerReorderReviewView(),
    );
  }
}

class _RetailerReorderReviewView extends StatelessWidget {
  const _RetailerReorderReviewView();

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: Text(
          i18n.reorderPreviewTitle,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: BlocConsumer<RetailerOrdersCubit, RetailerOrdersState>(
        listener: (context, state) async {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            AppToast.error(context, state.errorMessage!);
            context.read<RetailerOrdersCubit>().clearMessages();
            return;
          }

          if (state.successMessage == 'ORDER_REORDERED') {
            AppToast.success(context, i18n.reorderReadyForCheckout);

            if (state.skippedReorderItems.isNotEmpty) {
              await _showSkippedItemsDialog(context, state.skippedReorderItems);
            }

            if (!context.mounted) return;
            context.read<RetailerOrdersCubit>().clearMessages();
            context.push('/retailer-checkout');
          }
        },
        builder: (context, state) {
          final order = state.selectedOrder;

          if (state.isDetailsLoading && order == null) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (order == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  state.errorMessage ?? i18n.noFilteredOrders,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }

          final items = order.items;
          final total = items.fold<double>(
            0,
            (sum, item) => sum + item.totalPrice,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _ReorderInfoCard(order: order),
              const SizedBox(height: 14),
              _ReorderItemsCard(items: items),
              const SizedBox(height: 14),
              _ReorderSummaryCard(
                itemsCount: items.fold<int>(0, (sum, item) => sum + item.quantity),
                total: total > 0 ? total : order.totalAmount,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: state.isDetailsLoading
                      ? null
                      : () => _handleReorderTap(context, order.id),
                  icon: state.isDetailsLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.payment_rounded),
                  label: Text(
                    i18n.proceedToCheckout,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/retailer-dashboard'),
                  icon: const Icon(Icons.storefront_outlined),
                  label: Text(
                    i18n.continueShopping,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeTokens.textPrimary,
                    side: const BorderSide(color: AppThemeTokens.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                i18n.reorderCartChoiceHint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _handleReorderTap(BuildContext context, int orderId) async {
  final cubit = context.read<RetailerOrdersCubit>();

  String mode = 'REPLACE';

  try {
    final cart = await sl<RetailerCartService>().getCart();

    if (!context.mounted) return;

    if (cart.items.isNotEmpty) {
      final choice = await _showCartChoiceDialog(context);
      if (choice == null) return;
      mode = choice == _ReorderCartChoice.add ? 'ADD' : 'REPLACE';
    }
  } catch (_) {
    // If the current cart can't be checked, fall back to the default
    // REPLACE behavior rather than blocking the re-order action.
  }

  if (!context.mounted) return;
  cubit.reorder(orderId: orderId, mode: mode);
}

Future<_ReorderCartChoice?> _showCartChoiceDialog(BuildContext context) {
  final i18n = RetailerOrderI18n(context);

  return showDialog<_ReorderCartChoice>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          i18n.reorderCartChoiceTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(i18n.reorderCartChoiceMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(i18n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(_ReorderCartChoice.replace),
            child: Text(i18n.replaceCurrentCart),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_ReorderCartChoice.add),
            child: Text(i18n.addToCurrentCart),
          ),
        ],
      );
    },
  );
}

Future<void> _showSkippedItemsDialog(
  BuildContext context,
  List<SkippedReorderItemEntity> skippedItems,
) {
  final i18n = RetailerOrderI18n(context);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          i18n.someItemsSkippedTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: skippedItems
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          item.reason,
                          style: const TextStyle(
                            color: AppThemeTokens.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(i18n.ok),
          ),
        ],
      );
    },
  );
}

class _ReorderInfoCard extends StatelessWidget {
  final RetailerOrderEntity order;

  const _ReorderInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);

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
          Row(
            children: [
              Expanded(
                child: Text(
                  i18n.originalOrder,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              RetailerOrderStatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatRetailerOrderReference(order.orderNumber, order.id),
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            i18n.reorderPreviewSubtitle,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReorderItemsCard extends StatelessWidget {
  final List<RetailerOrderItemEntity> items;

  const _ReorderItemsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);

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
          Text(
            i18n.reorderItems,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              i18n.noFilteredOrders,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    RetailerProductImage(
                      imageUrl: item.imageUrl,
                      width: 58,
                      height: 58,
                      borderRadius: 14,
                      iconSize: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppThemeTokens.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} × ${formatRetailerOrderCurrency(context, item.unitPrice)}',
                            style: const TextStyle(
                              color: AppThemeTokens.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatRetailerOrderCurrency(context, item.totalPrice),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReorderSummaryCard extends StatelessWidget {
  final int itemsCount;
  final double total;

  const _ReorderSummaryCard({
    required this.itemsCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);

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
          Text(
            i18n.reorderSummary,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryLine(
            label: i18n.orderItems,
            value: i18n.itemsCount(itemsCount),
          ),
          const SizedBox(height: 10),
          _SummaryLine(
            label: i18n.totalAmount,
            value: formatRetailerOrderCurrency(context, total),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryLine({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: highlight
                ? Theme.of(context).colorScheme.primary
                : AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
