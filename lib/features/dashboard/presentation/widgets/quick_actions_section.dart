import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../data/models/retailer_home_model.dart';

class QuickActionsSection extends StatelessWidget {
  /// Kept because the dashboard already passes actions from backend/home model.
  ///
  /// Old generic AI Assistant is intentionally removed because AI is now
  /// product-specific and appears inside product cards.
  ///
  /// Rendered quick actions:
  /// - Create RFQ
  /// - Loyalty Points
  /// - Promotions
  ///
  /// Live Chat is removed.
  /// Top Ranking remains only in the bottom navbar.
  final List<QuickActionModel> actions;

  const QuickActionsSection({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final quickActions = [
      _RetailerQuickActionUiModel(
        title: l10n.createRfq,
        subtitle: l10n.requestQuotesQuickly,
        icon: Icons.description_outlined,
        iconColor: const Color(0xFFEC4899),
        iconBackgroundColor: const Color(0xFFFFE4EF),
        route: '/retailer-rfqs/create',
      ),
      _RetailerQuickActionUiModel(
        title: l10n.loyaltyPoints,
        subtitle: l10n.trackYourRewards,
        icon: Icons.star_border_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBackgroundColor: const Color(0xFFFFF3C4),
        route: '/retailer-loyalty',
      ),
      _RetailerQuickActionUiModel(
        title: l10n.promotions,
        subtitle: l10n.viewAvailableDeals,
        icon: Icons.local_offer_outlined,
        iconColor: const Color(0xFF10B981),
        iconBackgroundColor: const Color(0xFFDDFBEA),
        route: '/retailer-promotions',
      ),
    ];

    if (quickActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppThemeTokens.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),

        /// Full-width row cards.
        /// This prevents title/description truncation and avoids overflow.
        ListView.separated(
          itemCount: quickActions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _QuickActionCard(action: quickActions[index]);
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _RetailerQuickActionUiModel action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(action.route),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          border: Border.all(color: AppThemeTokens.border),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: action.iconBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(action.icon, color: action.iconColor, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppThemeTokens.textSecondary,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _RetailerQuickActionUiModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String route;

  const _RetailerQuickActionUiModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.route,
  });
}
