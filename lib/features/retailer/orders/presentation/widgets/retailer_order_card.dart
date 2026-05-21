import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/retailer_order_entity.dart';
import '../utils/retailer_order_formatters.dart';
import '../utils/retailer_order_i18n.dart';
import 'retailer_order_status_chip.dart';

class RetailerOrderCard extends StatelessWidget {
  final RetailerOrderEntity order;
  final VoidCallback onTrack;
  final VoidCallback? onCancel;
  final VoidCallback? onReorder;

  const RetailerOrderCard({
    super.key,
    required this.order,
    required this.onTrack,
    this.onCancel,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = RetailerOrderI18n(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              RetailerOrderStatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formatRetailerOrderDate(context, order.createdAt),
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                formatRetailerOrderCurrency(context, order.totalAmount),
                style: TextStyle(
                  color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppThemeTokens.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor(context).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _statusIcon(),
                    color: _statusColor(context),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.branchName?.trim().isNotEmpty == true
                            ? order.branchName!.trim()
                            : i18n.deliveryBranch,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        i18n.itemsCount(order.totalItems),
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.local_shipping_outlined, size: 19),
                    label: Text(
                      i18n.trackOrder,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              if (order.canReorder && onReorder != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: onReorder,
                      icon: const Icon(
                        Icons.shopping_cart_checkout_outlined,
                        size: 19,
                      ),
                      label: Text(
                        i18n.reorder,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeTokens.textPrimary,
                        side: const BorderSide(color: AppThemeTokens.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (order.canCancel && onCancel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeTokens.error,
                  side: BorderSide(
                    color: AppThemeTokens.error.withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  i18n.cancelOrder,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _statusIcon() {
    switch (order.status) {
      case RetailerOrderStatus.delivered:
        return Icons.check_circle_rounded;
      case RetailerOrderStatus.cancelled:
        return Icons.cancel_rounded;
      case RetailerOrderStatus.shipped:
        return Icons.local_shipping_rounded;
      case RetailerOrderStatus.preparing:
        return Icons.inventory_2_rounded;
      case RetailerOrderStatus.accepted:
        return Icons.verified_rounded;
      case RetailerOrderStatus.pending:
        return Icons.schedule_rounded;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (order.status) {
      case RetailerOrderStatus.delivered:
        return const Color(0xFF16A34A);
      case RetailerOrderStatus.cancelled:
        return AppThemeTokens.error;
      case RetailerOrderStatus.shipped:
        return const Color(0xFF7C3AED);
      case RetailerOrderStatus.preparing:
        return const Color(0xFF2563EB);
      case RetailerOrderStatus.accepted:
        return Theme.of(context).colorScheme.primary;
      case RetailerOrderStatus.pending:
        return const Color(0xFFF59E0B);
    }
  }
}
