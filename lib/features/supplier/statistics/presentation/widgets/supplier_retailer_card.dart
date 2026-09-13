import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_retailer_entity.dart';

/// One retailer in the supplier's list: who they are, how to reach them, and a
/// tap target that opens the contact popup.
class SupplierRetailerCard extends StatelessWidget {
  final SupplierRetailerEntity retailer;
  final VoidCallback onTap;

  const SupplierRetailerCard({
    super.key,
    required this.retailer,
    required this.onTap,
  });

  static String _fmtDate(DateTime? date) {
    if (date == null) return '';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canContact = retailer.canBeContacted;

    // The contact line is the reason this screen exists, so it gets the strong
    // colour when it's there and a plain "no way to reach them" when it isn't.
    final contactLine = <String>[
      if (retailer.hasPhone) retailer.phoneNumber.trim(),
      if (retailer.hasEmail) retailer.email.trim(),
    ].join('  •  ');

    final location = retailer.location;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canContact ? onTap : null,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
            border: Border.all(color: AppThemeTokens.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(initial: retailer.initial),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      retailer.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    // The shop name is what a supplier actually recognises, so
                    // it stays even when it is also the display name's source.
                    if (retailer.storeName.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          location.isEmpty
                              ? retailer.storeName.trim()
                              : '${retailer.storeName.trim()} — $location',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      canContact
                          ? contactLine
                          : l10n.supplierStatisticsNoContactDetails,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: canContact
                            ? AppThemeTokens.textPrimary
                            : AppThemeTokens.textSecondary,
                        fontStyle:
                            canContact ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                    if (retailer.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.supplierStatisticsJoinedOn(
                            _fmtDate(retailer.createdAt),
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppThemeTokens.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (canContact)
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: AppThemeTokens.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;

  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppThemeTokens.primary.withOpacity(0.12),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppThemeTokens.primary,
        ),
      ),
    );
  }
}
