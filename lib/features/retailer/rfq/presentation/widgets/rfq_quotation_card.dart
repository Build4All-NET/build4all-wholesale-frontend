import 'package:flutter/material.dart';

import '../../../../../core/currency/currency_formatter.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/rfq_quotation_entity.dart';

class RfqQuotationCard extends StatelessWidget {
  final RfqQuotationEntity quotation;
  final bool isSubmitting;
  final VoidCallback? onAccept;

  const RfqQuotationCard({
    super.key,
    required this.quotation,
    required this.isSubmitting,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedStatus = quotation.status.toUpperCase();
    final isAccepted = normalizedStatus == 'ACCEPTED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAccepted ? const Color(0xFF16A34A) : AppThemeTokens.border,
          width: isAccepted ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
                child: Icon(
                  Icons.storefront_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _supplierName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _QuotationStatusChip(status: quotation.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PriceBox(
                  title: l10n.rfqUnitPrice,
                  value: CurrencyFormatter.format(context, quotation.unitPrice),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PriceBox(
                  title: l10n.rfqTotal,
                  value: CurrencyFormatter.format(context, quotation.totalPrice),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.inventory_2_outlined,
                label: l10n.rfqQuantityLabel(
                  quotation.availableQuantity ?? 0,
                  'units',
                ),
              ),
              _MetaChip(
                icon: Icons.local_shipping_outlined,
                label: quotation.shippingCost == null
                    ? l10n.rfqShippingNotSpecified
                    : l10n.rfqShippingCost(
                        CurrencyFormatter.format(context, quotation.shippingCost),
                      ),
              ),
              if (quotation.deliveryDate != null)
                _MetaChip(
                  icon: Icons.event_outlined,
                  label: _formatDate(quotation.deliveryDate!),
                ),
            ],
          ),
          if (quotation.message != null &&
              quotation.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              quotation.message!,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (onAccept != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onAccept,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  l10n.rfqAcceptQuotation,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _supplierName {
    final username = quotation.supplierUsername?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }

    final email = quotation.supplierEmail?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return 'Supplier';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _QuotationStatusChip extends StatelessWidget {
  final String status;

  const _QuotationStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();

    final config = switch (normalized) {
      'ACCEPTED' => const _QuotationStatusConfig(
        label: 'ACCEPTED',
        icon: Icons.check_circle_outline_rounded,
        color: Color(0xFF16A34A),
        background: Color(0xFFDCFCE7),
      ),
      'REJECTED' => const _QuotationStatusConfig(
        label: 'REJECTED',
        icon: Icons.cancel_outlined,
        color: Color(0xFFDC2626),
        background: Color(0xFFFEE2E2),
      ),
      'WITHDRAWN' => const _QuotationStatusConfig(
        label: 'WITHDRAWN',
        icon: Icons.undo_rounded,
        color: Color(0xFFB45309),
        background: Color(0xFFFEF3C7),
      ),
      _ => const _QuotationStatusConfig(
        label: 'PENDING',
        icon: Icons.hourglass_empty_rounded,
        color: Color(0xFF475569),
        background: Color(0xFFF1F5F9),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotationStatusConfig {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _QuotationStatusConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}

class _PriceBox extends StatelessWidget {
  final String title;
  final String value;

  const _PriceBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeTokens.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppThemeTokens.textSecondary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
