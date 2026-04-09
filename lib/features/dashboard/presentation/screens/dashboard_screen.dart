import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_tokens.dart';

class DashboardScreen extends StatelessWidget {
  final String? title;

  const DashboardScreen({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppThemeTokens.textPrimary,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Dashboard Placeholder',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

