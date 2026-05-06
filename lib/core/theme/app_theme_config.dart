import 'package:flutter/material.dart';

import 'remote_theme_dto.dart';

Color _parseColor(dynamic value, String fallback) {
  var cleaned =
      (value?.toString().trim().isNotEmpty == true
              ? value.toString()
              : fallback)
          .replaceAll('#', '')
          .trim();

  if (cleaned.length == 6) {
    cleaned = 'FF$cleaned';
  }

  return Color(int.parse(cleaned, radix: 16));
}

double _doubleValue(dynamic value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _boolValue(dynamic value, bool fallback) {
  if (value is bool) return value;

  if (value is String) {
    return value.toLowerCase() == 'true';
  }

  return fallback;
}

class AppThemeConfig {
  final Color seedColor;
  final Brightness brightness;

  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color inputFill;
  final Color error;
  final Color danger;
  final Color muted;
  final Color success;

  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;

  final double buttonHeight;
  final double buttonTextSize;
  final bool buttonFullWidth;

  final double cardPadding;
  final double cardElevation;
  final double cardImageHeight;
  final bool cardShowShadow;
  final bool cardShowBorder;

  final String menuType;

  const AppThemeConfig({
    required this.seedColor,
    this.brightness = Brightness.light,
    this.onPrimary = Colors.white,
    this.background = const Color(0xFFF8FAFC),
    this.surface = Colors.white,
    this.textPrimary = const Color(0xFF111827),
    this.textSecondary = const Color(0xFF374151),
    this.border = const Color(0xFFE5E7EB),
    this.inputFill = const Color(0xFFF9FAFB),
    this.error = const Color(0xFFDC2626),
    this.danger = const Color(0xFFDC2626),
    this.muted = const Color(0xFF9CA3AF),
    this.success = const Color(0xFF16A34A),
    this.radiusSmall = 8,
    this.radiusMedium = 12,
    this.radiusLarge = 16,
    this.buttonHeight = 48,
    this.buttonTextSize = 15,
    this.buttonFullWidth = true,
    this.cardPadding = 12,
    this.cardElevation = 2,
    this.cardImageHeight = 120,
    this.cardShowShadow = true,
    this.cardShowBorder = true,
    this.menuType = 'bottom',
  });

  factory AppThemeConfig.fallback() {
    return const AppThemeConfig(
      seedColor: Color(0xFF16A34A),
      brightness: Brightness.light,
    );
  }

  factory AppThemeConfig.fromRemote(RemoteThemeDto remote) {
    final valuesMobile = remote.valuesMobile;

    final colors =
        (valuesMobile['colors'] as Map<String, dynamic>?) ?? const {};
    final card = (valuesMobile['card'] as Map<String, dynamic>?) ?? const {};
    final button =
        (valuesMobile['button'] as Map<String, dynamic>?) ?? const {};

    final primary = _parseColor(colors['primary'], '#16A34A');
    final cardRadius = _doubleValue(card['radius'], 12);

    return AppThemeConfig(
      seedColor: primary,
      brightness: Brightness.light,
      onPrimary: _parseColor(colors['onPrimary'], '#FFFFFF'),
      background: _parseColor(colors['background'], '#F8FAFC'),
      surface: _parseColor(colors['surface'], '#FFFFFF'),
      textPrimary: _parseColor(colors['label'], '#111827'),
      textSecondary: _parseColor(colors['body'], '#374151'),
      border: _parseColor(colors['border'], '#E5E7EB'),
      inputFill: _parseColor(colors['surface'], '#F9FAFB'),
      error: _parseColor(colors['error'], '#DC2626'),
      danger: _parseColor(colors['danger'], '#DC2626'),
      muted: _parseColor(colors['muted'], '#9CA3AF'),
      success: _parseColor(colors['success'], '#16A34A'),
      radiusSmall: cardRadius,
      radiusMedium: cardRadius + 4,
      radiusLarge: cardRadius + 8,
      buttonHeight: _doubleValue(button['height'], 48),
      buttonTextSize: _doubleValue(button['textSize'], 15),
      buttonFullWidth: _boolValue(button['fullWidth'], true),
      cardPadding: _doubleValue(card['padding'], 12),
      cardElevation: _doubleValue(card['elevation'], 2),
      cardImageHeight: _doubleValue(card['imageHeight'], 120),
      cardShowShadow: _boolValue(card['showShadow'], true),
      cardShowBorder: _boolValue(card['showBorder'], true),
      menuType: (remote.menuType ?? 'bottom').toLowerCase(),
    );
  }

  AppThemeConfig copyWith({
    Color? seedColor,
    Brightness? brightness,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? inputFill,
    Color? error,
    Color? danger,
    Color? muted,
    Color? success,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? buttonHeight,
    double? buttonTextSize,
    bool? buttonFullWidth,
    double? cardPadding,
    double? cardElevation,
    double? cardImageHeight,
    bool? cardShowShadow,
    bool? cardShowBorder,
    String? menuType,
  }) {
    return AppThemeConfig(
      seedColor: seedColor ?? this.seedColor,
      brightness: brightness ?? this.brightness,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      inputFill: inputFill ?? this.inputFill,
      error: error ?? this.error,
      danger: danger ?? this.danger,
      muted: muted ?? this.muted,
      success: success ?? this.success,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      buttonTextSize: buttonTextSize ?? this.buttonTextSize,
      buttonFullWidth: buttonFullWidth ?? this.buttonFullWidth,
      cardPadding: cardPadding ?? this.cardPadding,
      cardElevation: cardElevation ?? this.cardElevation,
      cardImageHeight: cardImageHeight ?? this.cardImageHeight,
      cardShowShadow: cardShowShadow ?? this.cardShowShadow,
      cardShowBorder: cardShowBorder ?? this.cardShowBorder,
      menuType: menuType ?? this.menuType,
    );
  }
}
