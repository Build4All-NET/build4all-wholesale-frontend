import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/storage/branding_storage.dart';
import '../../../../core/theme/app_theme_tokens.dart';

class AuthHeader extends StatefulWidget {
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
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader> {
  String? _appName;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _loadBranding();
  }

  Future<void> _loadBranding() async {
    final storage = BrandingStorage();

    final storedAppName = await storage.getAppName();
    final storedLogoUrl = await storage.getLogoUrl();

    if (!mounted) return;

    setState(() {
      _appName = storedAppName;
      _logoUrl = storedLogoUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAppName =
        (_appName != null && _appName!.trim().isNotEmpty)
            ? _appName!.trim()
            : AppConfig.appName;

    final effectiveLogoUrl =
        (_logoUrl != null && _logoUrl!.trim().isNotEmpty)
            ? _logoUrl!.trim()
            : '';

    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: widget.iconBackgroundColor,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: effectiveLogoUrl.isNotEmpty
              ? Image.network(
                  effectiveLogoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/branding/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      widget.icon,
                      size: 38,
                      color: widget.iconColor,
                    ),
                  ),
                )
              : Image.asset(
                  'assets/branding/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    widget.icon,
                    size: 38,
                    color: widget.iconColor,
                  ),
                ),
        ),
        const SizedBox(height: 20),
        Text(
          effectiveAppName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppThemeTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}