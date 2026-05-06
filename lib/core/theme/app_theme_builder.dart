import 'package:flutter/material.dart';

import 'app_theme_config.dart';

class AppThemeBuilder {
  static ThemeData buildTheme(AppThemeConfig config) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.seedColor,
      brightness: config.brightness,
      primary: config.seedColor,
      onPrimary: config.onPrimary,
      surface: config.surface,
      error: config.error,
      onError: config.onPrimary,
    );

    final isDark = config.brightness == Brightness.dark;

    final background = isDark ? const Color(0xFF0F172A) : config.background;
    final surface = isDark ? const Color(0xFF111827) : config.surface;
    final inputFill = isDark ? const Color(0xFF1E293B) : config.inputFill;
    final textPrimary = isDark ? Colors.white : config.textPrimary;
    final textSecondary = isDark ? Colors.white70 : config.textSecondary;
    final border = isDark ? Colors.white12 : config.border;

    return ThemeData(
      useMaterial3: true,
      brightness: config.brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      primaryColor: config.seedColor,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : config.muted,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: config.seedColor,
        suffixIconColor: config.seedColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.radiusMedium),
          borderSide: BorderSide(color: border, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.radiusMedium),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.radiusMedium),
          borderSide: BorderSide(color: config.seedColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.radiusMedium),
          borderSide: BorderSide(color: config.error, width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.radiusMedium),
          borderSide: BorderSide(color: config.error, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.seedColor,
          foregroundColor: config.onPrimary,
          elevation: 0,
          minimumSize: Size(
            config.buttonFullWidth ? double.infinity : 0,
            config.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.radiusMedium),
          ),
          textStyle: TextStyle(
            fontSize: config.buttonTextSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: config.cardShowShadow ? config.cardElevation : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.radiusLarge),
          side: config.cardShowBorder
              ? BorderSide(color: border)
              : BorderSide.none,
        ),
      ),
    );
  }
}