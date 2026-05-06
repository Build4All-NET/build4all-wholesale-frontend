import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';

class RetailerHomeHeader extends StatelessWidget {
  final String welcomeName;
  final int notificationCount;
  final int cartCount;

  /// Called when notification bell is clicked
  final VoidCallback onNotificationsTap;

  /// Called when cart icon is clicked
  final VoidCallback onCartTap;

  const RetailerHomeHeader({
    super.key,
    required this.welcomeName,
    required this.notificationCount,
    required this.cartCount,
    required this.onNotificationsTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Welcome section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeBack,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                welcomeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),

        /// Notification button
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          badgeCount: notificationCount,
          primaryColor: primaryColor,
          onTap: onNotificationsTap,
        ),

        const SizedBox(width: 12),

        /// Cart button
        _HeaderIconButton(
          icon: Icons.shopping_cart_outlined,
          badgeCount: cartCount,
          primaryColor: primaryColor,
          onTap: onCartTap,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final Color primaryColor;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.badgeCount,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppThemeTokens.border),
            ),
            child: Icon(icon, color: AppThemeTokens.textPrimary, size: 28),
          ),

          /// Badge
          if (badgeCount > 0)
            PositionedDirectional(
              top: -4,
              end: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppThemeTokens.error,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
