import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../shared/utils/supplier_formatters.dart';
import '../../domain/entities/supplier_rfq_quotation_entity.dart';
import '../utils/supplier_rfq_i18n.dart';
import 'supplier_rfq_status_chip.dart';

class SupplierRfqQuotationCard extends StatelessWidget {
  final SupplierRfqQuotationEntity quotation;
  final VoidCallback? onEdit;
  final VoidCallback? onWithdraw;

  const SupplierRfqQuotationCard({
    super.key,
    required this.quotation,
    this.onEdit,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final l = SupplierRfqI18n(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.request_quote_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.t('yourQuotation'),
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SupplierRfqStatusChip(status: quotation.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoTile(label: l.t('unitPrice'), value: quotation.unitPrice.toStringAsFixed(2)),
              _InfoTile(label: l.t('total'), value: quotation.totalPrice.toStringAsFixed(2)),
              if (quotation.availableQuantity != null)
                _InfoTile(label: l.t('availableQty'), value: quotation.availableQuantity.toString()),
              _InfoTile(label: l.t('shipping'), value: (quotation.shippingCost ?? 0).toStringAsFixed(2)),
              if (quotation.deliveryDate != null)
                _InfoTile(label: l.t('deliveryDate'), value: formatSupplierShortDate(context, quotation.deliveryDate!)),
            ],
          ),
          if (quotation.message != null && quotation.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              quotation.message!,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
          if (quotation.isAccepted) ...[
            const SizedBox(height: 12),
            _Notice(
              icon: Icons.check_circle_outline_rounded,
              text: l.t('quotationAccepted'),
              color: const Color(0xFF16A34A),
            ),
          ],
          if (quotation.isRejected) ...[
            const SizedBox(height: 12),
            _Notice(
              icon: Icons.cancel_outlined,
              text: l.status('REJECTED'),
              color: AppThemeTokens.error,
            ),
          ],
          if (quotation.isWithdrawn) ...[
            const SizedBox(height: 12),
            _Notice(
              icon: Icons.undo_rounded,
              text: l.status('WITHDRAWN'),
              color: AppThemeTokens.textSecondary,
            ),
          ],
          if (onEdit != null || onWithdraw != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l.t('edit')),
                    ),
                  ),
                if (onEdit != null && onWithdraw != null) const SizedBox(width: 10),
                if (onWithdraw != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onWithdraw,
                      icon: const Icon(Icons.close_rounded),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeTokens.error,
                        side: const BorderSide(color: AppThemeTokens.error),
                      ),
                      label: Text(l.t('withdraw')),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Notice({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
