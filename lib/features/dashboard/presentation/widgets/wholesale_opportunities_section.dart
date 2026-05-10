import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';

class WholesaleOpportunitiesSection extends StatelessWidget {
  final GroupDeliveryModel? groupDelivery;

  const WholesaleOpportunitiesSection({
    super.key,
    required this.groupDelivery,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final cards = <Widget>[
      _OpportunityCard(
        icon: Icons.inventory_2_outlined,
        title: 'Bulk Orders',
        description: 'Save more when ordering larger quantities from suppliers.',
        actionLabel: context.l10n.viewAvailableDeals,
        color: primaryColor,
      ),
    ];

    final delivery = groupDelivery;

    if (delivery != null && delivery.available) {
      cards.add(
        _OpportunityCard(
          icon: Icons.local_shipping_outlined,
          title: delivery.title,
          description: delivery.description,
          actionLabel: delivery.ctaLabel,
          color: primaryColor,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wholesale Opportunities',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppThemeTokens.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: cards
              .map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: card,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final Color color;

  const _OpportunityCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}