import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/rfq_request_entity.dart';
import 'rfq_status_chip.dart';

class RfqCard extends StatelessWidget {
  final RfqRequestEntity rfq;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const RfqCard({
    super.key,
    required this.rfq,
    required this.onTap,
    this.onEdit,
    this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final hasActions =
        (rfq.canEdit && onEdit != null) ||
        (rfq.canCancel && onCancel != null) ||
        (rfq.canDelete && onDelete != null);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          border: Border.all(color: AppThemeTokens.border),
          borderRadius: BorderRadius.circular(18),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBox(status: rfq.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rfq.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        rfq.requirements,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppThemeTokens.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RfqStatusChip(status: rfq.status),
                    if (hasActions) ...[
                      const SizedBox(height: 6),
                      PopupMenuButton<_RfqCardAction>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: AppThemeTokens.textSecondary,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _RfqCardAction.edit:
                              onEdit?.call();
                              break;
                            case _RfqCardAction.cancel:
                              onCancel?.call();
                              break;
                            case _RfqCardAction.delete:
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            if (rfq.canEdit && onEdit != null)
                              PopupMenuItem(
                                value: _RfqCardAction.edit,
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit_outlined),
                                    const SizedBox(width: 10),
                                    Text(l10n.rfqEditRequest),
                                  ],
                                ),
                              ),
                            if (rfq.canCancel && onCancel != null)
                              PopupMenuItem(
                                value: _RfqCardAction.cancel,
                                child: Row(
                                  children: [
                                    const Icon(Icons.cancel_outlined),
                                    const SizedBox(width: 10),
                                    Text(l10n.rfqCancelRequest),
                                  ],
                                ),
                              ),
                            if (rfq.canDelete && onDelete != null)
                              PopupMenuItem(
                                value: _RfqCardAction.delete,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppThemeTokens.error,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      l10n.rfqDeleteRequest,
                                      style: const TextStyle(
                                        color: AppThemeTokens.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ];
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.inventory_2_outlined,
                  label: l10n.rfqQuantityLabel(rfq.quantity, rfq.unit),
                ),
                _MetaChip(
                  icon: Icons.local_shipping_outlined,
                  label: _deliveryLabel(l10n, rfq.preferredDeliveryLabel),
                ),
                _MetaChip(
                  icon: Icons.request_quote_outlined,
                  label: l10n.rfqQuotesCount(rfq.quotationsCount),
                ),
                if (rfq.categoryName != null)
                  _MetaChip(
                    icon: Icons.category_outlined,
                    label: rfq.categoryName!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _deliveryLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'Within 24 hours' => l10n.rfqDeliveryWithin24Hours,
      'Within 2-3 days' => l10n.rfqDelivery2To3Days,
      'Within 1 week' => l10n.rfqDeliveryWithin1Week,
      'Within 2 weeks' => l10n.rfqDeliveryWithin2Weeks,
      'Flexible' => l10n.rfqDeliveryFlexible,
      _ => value,
    };
  }
}

enum _RfqCardAction { edit, cancel, delete }

class _IconBox extends StatelessWidget {
  final String status;

  const _IconBox({required this.status});

  @override
  Widget build(BuildContext context) {
    final accepted = status.toUpperCase() == 'ACCEPTED';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accepted
            ? const Color(0xFFDCFCE7)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        accepted ? Icons.check_rounded : Icons.description_outlined,
        color: accepted
            ? const Color(0xFF16A34A)
            : Theme.of(context).colorScheme.primary,
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
      constraints: const BoxConstraints(maxWidth: 210),
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
