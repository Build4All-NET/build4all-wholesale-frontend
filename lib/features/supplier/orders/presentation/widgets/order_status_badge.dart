import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  final SupplierOrderStatus status;

  OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    final backgroundColor = color.withValues(alpha: 0.12);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(context),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context) {
    switch (status) {
      case SupplierOrderStatus.pending:
        return context.l10n.orderStatusPending;
      case SupplierOrderStatus.accepted:
        return context.l10n.orderStatusAccepted;
      case SupplierOrderStatus.preparing:
        return context.l10n.orderStatusPreparing;
      case SupplierOrderStatus.shipped:
        return context.l10n.orderStatusShipped;
      case SupplierOrderStatus.delivered:
        return context.l10n.orderStatusDelivered;
      case SupplierOrderStatus.cancelled:
        return context.l10n.orderStatusCancelled;
    }
  }

  Color _getColor(BuildContext context) {
    switch (status) {
      case SupplierOrderStatus.pending:
        return Color(0xFFF97316);
      case SupplierOrderStatus.accepted:
        return Theme.of(context).colorScheme.primary;
      case SupplierOrderStatus.preparing:
        return Color(0xFF2563EB);
      case SupplierOrderStatus.shipped:
        return Color(0xFF7C3AED);
      case SupplierOrderStatus.delivered:
        return Theme.of(context).colorScheme.primary;
      case SupplierOrderStatus.cancelled:
        return AppThemeTokens.error;
    }
  }
}
