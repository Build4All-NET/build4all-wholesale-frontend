import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_order_entity.dart';
import 'order_status_badge.dart';

class SupplierOrderCard extends StatelessWidget {
  final SupplierOrderEntity order;
  final VoidCallback onViewDetails;

  SupplierOrderCard({
    super.key,
    required this.order,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              Text(
                _formatMoney(order.totalAmount),
                style: TextStyle(
                  color: primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.retailerName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDate(order.orderDate),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                    if (order.branchName != null &&
                        order.branchName!.trim().isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        order.branchName!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppThemeTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SmallPaymentBadge(text: order.paymentMethod),
                  SizedBox(height: 8),
                  OrderStatusBadge(status: order.status),
                ],
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 17,
                color: primary,
              ),
              SizedBox(width: 6),
              Text(
                context.l10n.itemsCountLabel(order.itemCount),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewDetails,
              icon: Icon(Icons.visibility_outlined, size: 20),
              label: Text(
                context.l10n.viewDetailsButton,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeTokens.textPrimary,
                side: BorderSide(color: AppThemeTokens.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusSmall,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final month = _monthName(date.month);
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$month ${date.day}, $hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month];
  }
}

class _SmallPaymentBadge extends StatelessWidget {
  final String text;

  _SmallPaymentBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppThemeTokens.textPrimary,
        ),
      ),
    );
  }
}
