import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/branding/app_brand_logo.dart';
import '../../../../core/branding/branding_cubit.dart';
import '../../../../core/branding/branding_state.dart';
import '../../../../core/theme/app_theme_tokens.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandingCubit, BrandingState>(
      builder: (context, brandingState) {
        final effectiveTitle = brandingState.appName.trim().isNotEmpty
            ? brandingState.appName.trim()
            : title;

        return Column(
          children: [
            AppBrandLogo(
              size: 82,
              iconSize: 38,
              fallbackIcon: icon,
              fallbackIconColor: iconColor,
              backgroundColor: iconBackgroundColor,
            ),
            const SizedBox(height: 20),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
