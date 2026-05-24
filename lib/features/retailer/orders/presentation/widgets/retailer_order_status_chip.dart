import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/retailer_order_entity.dart';
import '../utils/retailer_order_i18n.dart';

class RetailerOrderStatusChip extends StatelessWidget {
  final RetailerOrderStatus status;

  const RetailerOrderStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final label = RetailerOrderI18n(context).statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _color(BuildContext context) {
    switch (status) {
      case RetailerOrderStatus.pending:
        return const Color(0xFFF59E0B);
      case RetailerOrderStatus.accepted:
        return Theme.of(context).colorScheme.primary;
      case RetailerOrderStatus.preparing:
        return const Color(0xFF2563EB);
      case RetailerOrderStatus.shipped:
        return const Color(0xFF7C3AED);
      case RetailerOrderStatus.delivered:
        return const Color(0xFF16A34A);
      case RetailerOrderStatus.cancelled:
        return AppThemeTokens.error;
    }
  }
}
