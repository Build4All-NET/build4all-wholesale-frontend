import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/retailer_order_entity.dart';
import '../utils/retailer_order_formatters.dart';
import '../utils/retailer_order_i18n.dart';

class RetailerOrderSummaryCard extends StatelessWidget {
  final RetailerOrderEntity order;

  const RetailerOrderSummaryCard({
    super.key,
    required this.order,
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
            i18n.orderDetails,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: i18n.totalAmount,
            value: formatRetailerOrderCurrency(context, order.totalAmount),
            highlight: true,
          ),
          _SummaryRow(
            label: i18n.paymentMethod,
            value: i18n.paymentLabel(order.paymentMethod),
          ),
          _SummaryRow(
            label: i18n.deliveryBranch,
            value: order.branchName?.trim().isNotEmpty == true
                ? order.branchName!.trim()
                : i18n.notProvided,
          ),
          _SummaryRow(
            label: i18n.deliveryAddress,
            value: order.deliveryAddress.trim().isNotEmpty
                ? order.deliveryAddress.trim()
                : i18n.notProvided,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: highlight
                    ? Theme.of(context).colorScheme.primary
                    : AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
