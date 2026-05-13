import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../core/theme/app_theme_tokens.dart';

class SupplierQuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  SupplierQuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeTokens.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
          border: Border.all(color: AppThemeTokens.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppThemeTokens.textPrimary, size: 28),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
