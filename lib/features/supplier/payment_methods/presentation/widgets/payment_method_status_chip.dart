import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_tokens.dart';

class PaymentMethodStatusChip extends StatelessWidget {
  final bool enabled;
  final String enabledText;
  final String disabledText;

  const PaymentMethodStatusChip({
    super.key,
    required this.enabled,
    required this.enabledText,
    required this.disabledText,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF16A34A) : AppThemeTokens.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        enabled ? enabledText : disabledText,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
