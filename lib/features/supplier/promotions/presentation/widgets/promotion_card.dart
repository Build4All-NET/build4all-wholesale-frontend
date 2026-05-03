import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionCard extends StatelessWidget {
  final PromotionEntity promotion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PromotionCard({
    super.key,
    required this.promotion,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '—';

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  String _usageText() {
    if (promotion.maxUses == null) {
      return '${promotion.usedCount} / ∞';
    }

    return '${promotion.usedCount} / ${promotion.maxUses}';
  }

  String _remainingText() {
    if (promotion.remainingUses == null) return 'Unlimited';
    return promotion.remainingUses.toString();
  }

  String _validityText() {
    if (promotion.startsAt == null && promotion.endsAt == null) {
      return 'Always active';
    }

    return '${_formatDate(promotion.startsAt)} → ${_formatDate(promotion.endsAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: primary.withOpacity(0.12),
                child: Icon(
                  Icons.local_offer_outlined,
                  color: primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppThemeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${promotion.promotionType.label} • ${promotion.discountType.label} • ${promotion.discountLabel}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(promotion: promotion),
            ],
          ),
          if (promotion.description != null &&
              promotion.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Text(
            _validityText(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Used', value: _usageText()),
              _InfoChip(label: 'Remaining', value: _remainingText()),
              _InfoChip(
                label: 'Min order',
                value: promotion.minOrderAmount == null
                    ? '—'
                    : promotion.minOrderAmount!.toStringAsFixed(2),
              ),
              _InfoChip(
                label: 'Max discount',
                value: promotion.maxDiscountAmount == null
                    ? '—'
                    : promotion.maxDiscountAmount!.toStringAsFixed(2),
              ),
              _InfoChip(
                label: 'Branches',
                value: promotion.branchApplicabilityLabel,
              ),
              _InfoChip(
                label: 'Valid now',
                value: promotion.currentlyValid ? 'Yes' : 'No',
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppThemeTokens.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary.withOpacity(0.35)),
                      backgroundColor: primary.withOpacity(0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 17),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PromotionEntity promotion;

  const _StatusBadge({required this.promotion});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final Color backgroundColor;
    final Color textColor;

    switch (promotion.status) {
      case 'INACTIVE':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'SCHEDULED':
        backgroundColor = primary.withOpacity(0.12);
        textColor = primary;
        break;
      case 'EXPIRED':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'USAGE_LIMIT_REACHED':
        backgroundColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        break;
      case 'ACTIVE':
      default:
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        promotion.statusLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppThemeTokens.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: AppThemeTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}