import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_tokens.dart';

class SupplierQuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  SupplierQuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: AppThemeTokens.surface,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
            border: Border.all(color: AppThemeTokens.border),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 19,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    color: AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 3),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: AppThemeTokens.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
