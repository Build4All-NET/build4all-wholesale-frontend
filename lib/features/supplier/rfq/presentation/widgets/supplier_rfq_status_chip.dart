import 'package:flutter/material.dart';

import '../utils/supplier_rfq_i18n.dart';

class SupplierRfqStatusChip extends StatelessWidget {
  final String status;

  const SupplierRfqStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final style = _styleFor(normalized);
    final l = SupplierRfqI18n(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.foreground.withValues(alpha: 0.18)),
      ),
      child: Text(
        l.status(normalized),
        style: TextStyle(
          color: style.foreground,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  _ChipStyle _styleFor(String status) {
    switch (status) {
      case 'OPEN':
      case 'PENDING':
        return const _ChipStyle(Color(0xFFEFF6FF), Color(0xFF2563EB));
      case 'QUOTED':
        return const _ChipStyle(Color(0xFFFEF3C7), Color(0xFFD97706));
      case 'ACCEPTED':
        return const _ChipStyle(Color(0xFFDCFCE7), Color(0xFF16A34A));
      case 'REJECTED':
      case 'CANCELLED':
      case 'CLOSED':
      case 'EXPIRED':
        return const _ChipStyle(Color(0xFFFEE2E2), Color(0xFFDC2626));
      case 'WITHDRAWN':
        return const _ChipStyle(Color(0xFFF1F5F9), Color(0xFF64748B));
      default:
        return const _ChipStyle(Color(0xFFF1F5F9), Color(0xFF475569));
    }
  }
}

class _ChipStyle {
  final Color background;
  final Color foreground;

  const _ChipStyle(this.background, this.foreground);
}
