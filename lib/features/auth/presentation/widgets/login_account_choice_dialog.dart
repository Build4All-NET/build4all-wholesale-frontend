import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/login_account_type.dart';

class LoginAccountChoiceDialog extends StatelessWidget {
  const LoginAccountChoiceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              context.l10n.chooseHowToSignIn,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _ChoiceRow(
              icon: Icons.verified_user_outlined,
              iconColor: primaryColor,
              title: context.l10n.enterAsOwner,
              subtitle: context.l10n.supplierOwnerDashboard,
              onTap: () {
                Navigator.of(context).pop(LoginAccountType.supplier);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppThemeTokens.border),
            ),
            _ChoiceRow(
              icon: Icons.person_outline,
              iconColor: AppThemeTokens.textPrimary,
              title: context.l10n.enterAsUser,
              subtitle: context.l10n.retailerAccount,
              onTap: () {
                Navigator.of(context).pop(LoginAccountType.retailer);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMedium),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            SizedBox(width: 48, child: Icon(icon, color: iconColor, size: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppThemeTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppThemeTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
