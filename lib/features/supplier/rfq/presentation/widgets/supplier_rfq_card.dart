import 'package:flutter/material.dart';

import '../../../../../core/currency/currency_formatter.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_rfq_request_entity.dart';
import '../utils/supplier_rfq_i18n.dart';
import '../utils/supplier_rfq_image_url_helper.dart';
import 'supplier_rfq_status_chip.dart';

class SupplierRfqCard extends StatelessWidget {
  final SupplierRfqRequestEntity rfq;
  final VoidCallback onTap;

  const SupplierRfqCard({super.key, required this.rfq, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = buildSupplierRfqPublicImageUrl(rfq.imageUrl);
    final l = SupplierRfqI18n(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RfqImage(imageUrl: imageUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          rfq.productName.isEmpty ? l.t('unnamedProduct') : rfq.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppThemeTokens.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SupplierRfqStatusChip(status: rfq.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rfq.requirements.isEmpty ? l.t('noRequirementsAdded') : rfq.requirements,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(icon: Icons.inventory_2_outlined, label: rfq.quantityLabel),
                      _MetaChip(icon: Icons.location_on_outlined, label: rfq.deliveryLocationLabel),
                      _MetaChip(icon: Icons.local_shipping_outlined, label: rfq.preferredDeliveryLabel),
                      _MetaChip(
                        icon: Icons.request_quote_outlined,
                        label: l.quoteCount(rfq.quotationsCount),
                      ),
                      if (rfq.categoryName != null)
                        _MetaChip(icon: Icons.category_outlined, label: rfq.categoryName!),
                      if (rfq.targetUnitPrice != null)
                        _MetaChip(
                          icon: Icons.payments_outlined,
                          label: l.targetPrice(CurrencyFormatter.format(context, rfq.targetUnitPrice)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppThemeTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _RfqImage extends StatelessWidget {
  final String? imageUrl;

  const _RfqImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 72,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        child: imageUrl == null
            ? Icon(
                Icons.inventory_2_outlined,
                color: Theme.of(context).colorScheme.primary,
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
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
          Icon(icon, size: 14, color: AppThemeTokens.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeTokens.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
