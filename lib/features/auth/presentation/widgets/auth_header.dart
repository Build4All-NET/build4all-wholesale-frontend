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

    final appName = await storage.getAppName();
    final logoUrl = await storage.getLogoUrl();

    if (!mounted) return;

    setState(() {
      _appName = appName;
      _logoUrl = logoUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTitle =
        (_appName != null && _appName!.trim().isNotEmpty)
            ? _appName!
            : AppConfig.appName;

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
          child: (_logoUrl != null && _logoUrl!.trim().isNotEmpty)
              ? Image.network(
                  _logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    widget.icon,
                    size: 38,
                    color: widget.iconColor,
                  ),
                )
              : Icon(
                  widget.icon,
                  size: 38,
                  color: widget.iconColor,
                ),
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