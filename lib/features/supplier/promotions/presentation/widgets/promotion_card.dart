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
                title: promotion.title,
                primary: primary,
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
          Text(
            promotion.validityLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AmountChip(
                label: 'Min order',
                value: promotion.minOrderAmount,
                emptyValue: '—',
              ),
              _AmountChip(
                label: 'Max discount',
                value: promotion.maxDiscountAmount,
                emptyValue: '—',
              ),
              _TextChip(
                text: 'Branches: ${promotion.branchScopeLabel}',
              ),
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
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy,
                  label: 'Copy',
                  onPressed: onCopy,
                  borderColor: AppThemeTokens.border,
                  textColor: AppThemeTokens.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onPressed: onEdit,
                  borderColor: primary.withOpacity(0.35),
                  textColor: primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  onPressed: onDelete,
                  borderColor: Colors.red.withOpacity(0.45),
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
  final String title;
  final Color primary;

  const _PromotionBadge({
    required this.title,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final text = title.trim().isEmpty
        ? 'PROMO'
        : title.trim().split(RegExp(r'\s+')).take(2).join(' ').toUpperCase();

    return Container(
      width: 86,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: primary,
          width: 1.4,
        ),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: primary,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E8EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Color(0xFF9B4D6D),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final double? value;
  final String emptyValue;

  const _AmountChip({
    required this.label,
    required this.value,
    required this.emptyValue,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null ? emptyValue : value!.toStringAsFixed(2);

    return _TextChip(text: '$label: $displayValue');
  }
}

class _TextChip extends StatelessWidget {
  final String text;

  const _TextChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeTokens.border),
      ),
      child: Text(
        text,
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
  final VoidCallback? onPressed;
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
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}