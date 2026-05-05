import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  final SupplierOrderStatus status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    final backgroundColor = color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _getColor(BuildContext context) {
    switch (status) {
      case SupplierOrderStatus.pending:
        return const Color(0xFFF97316);
      case SupplierOrderStatus.accepted:
        return Theme.of(context).colorScheme.primary;
      case SupplierOrderStatus.preparing:
        return const Color(0xFF2563EB);
      case SupplierOrderStatus.shipped:
        return const Color(0xFF7C3AED);
      case SupplierOrderStatus.delivered:
        return Theme.of(context).colorScheme.primary;
      case SupplierOrderStatus.cancelled:
        return AppThemeTokens.error;
    }
  }
}