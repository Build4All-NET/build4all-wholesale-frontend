import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4all_wholesale_frontend/core/widgets/app_toast.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../cubit/retailer_orders_cubit.dart';
import '../cubit/retailer_orders_state.dart';
import '../utils/retailer_order_formatters.dart';
import '../utils/retailer_order_i18n.dart';
import '../widgets/retailer_order_items_section.dart';
import '../widgets/retailer_order_status_chip.dart';
import '../widgets/retailer_order_summary_card.dart';
import '../widgets/retailer_order_timeline.dart';

class RetailerOrderTrackingScreen extends StatelessWidget {
  final int orderId;

  const RetailerOrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RetailerOrdersCubit>()..loadOrderDetails(orderId: orderId),
      child: const _RetailerOrderTrackingView(),
    );
  }
}

class _RetailerOrderTrackingView extends StatelessWidget {
  const _RetailerOrderTrackingView();

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        title: Text(
          i18n.orderTracking,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 68,
                      color: AppThemeTokens.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? i18n.noFilteredOrders,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppThemeTokens.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              Container(
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
                            formatRetailerOrderReference(order.orderNumber, order.id),
                            style: const TextStyle(
                              color: AppThemeTokens.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order.branchName?.trim().isNotEmpty == true
                                ? order.branchName!.trim()
                                : i18n.deliveryBranch,
                            style: const TextStyle(
                              color: AppThemeTokens.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RetailerOrderStatusChip(status: order.status),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              RetailerOrderTimeline(order: order),
              const SizedBox(height: 14),
              RetailerOrderSummaryCard(order: order),
              const SizedBox(height: 14),
              RetailerOrderItemsSection(order: order),
              if (order.canCancel) ...[
                const SizedBox(height: 18),
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: state.isDetailsLoading
                        ? null
                        : () => _confirmCancel(context, order.id),
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      i18n.cancelOrder,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeTokens.error,
                      side: BorderSide(
                        color: AppThemeTokens.error.withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, int orderId) async {
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
      context.read<RetailerOrdersCubit>().cancelOrder(orderId: orderId);
    }
  }
}
