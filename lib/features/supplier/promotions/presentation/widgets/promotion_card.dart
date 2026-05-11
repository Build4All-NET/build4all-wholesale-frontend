import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionCard extends StatelessWidget {
  final PromotionEntity promotion;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PromotionCard({
    super.key,
    required this.promotion,
    this.onCopy,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PromotionBadge(
                primary: primary,
                discountLabel: promotion.discountLabel,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${promotion.discountTypeLabel} • ${promotion.discountLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(status: promotion.statusLabel),
            ],
          ),
          if (promotion.description != null &&
              promotion.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              promotion.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TextChip(text: promotion.targetLabel),
              _TextChip(text: promotion.validityLabel),
              _TextChip(text: promotion.minOrderLabel),
              _TextChip(text: promotion.maxDiscountLabel),
              _TextChip(text: 'Branches: ${promotion.branchScopeLabel}'),
              _TextChip(
                text: 'Valid now: ${promotion.currentlyValid ? 'Yes' : 'No'}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppThemeTokens.border),
          const SizedBox(height: 14),
          Row(
            children: [
              if (onCopy != null) ...[
                Expanded(
                  child: _ActionButton(
                    icon: Icons.copy_outlined,
                    label: 'Copy',
                    onPressed: onCopy!,
                    borderColor: AppThemeTokens.border,
                    textColor: AppThemeTokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (onEdit != null) ...[
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onPressed: onEdit!,
                    borderColor: primary.withValues(alpha: 0.35),
                    textColor: primary,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (onDelete != null)
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    onPressed: onDelete!,
                    borderColor: Colors.red.withValues(alpha: 0.45),
                    textColor: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromotionBadge extends StatelessWidget {
  final Color primary;
  final String discountLabel;

  const _PromotionBadge({
    required this.primary,
    required this.discountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: primary.withValues(alpha: 0.12),
      child: Icon(
        Icons.local_offer_outlined,
        color: primary,
        size: 28,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final active = normalized == 'active';
    final scheduled = normalized == 'scheduled';
    final expired = normalized == 'expired';

    final background = active
        ? const Color(0xFFE8F7EF)
        : scheduled
            ? const Color(0xFFEFF6FF)
            : expired
                ? const Color(0xFFFFF7ED)
                : const Color(0xFFF4E8EE);

    final textColor = active
        ? const Color(0xFF15803D)
        : scheduled
            ? const Color(0xFF1D4ED8)
            : expired
                ? const Color(0xFFC2410C)
                : const Color(0xFF9B4D6D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }
}

class _TextChip extends StatelessWidget {
  final String text;

  const _TextChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppThemeTokens.textPrimary,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          minimumSize: const Size(0, 46),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}