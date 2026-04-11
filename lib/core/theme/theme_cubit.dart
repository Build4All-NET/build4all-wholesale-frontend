import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/theme_storage.dart';
import 'app_theme_config.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeStorage themeStorage;

  ThemeCubit(this.themeStorage)
      : super(
          const ThemeState(
            config: AppThemeConfig(
              seedColor: Color(0xFF16A34A),
              brightness: Brightness.light,
            ),
          ),
        );

  Future<void> loadSavedTheme() async {
    final savedColor = await themeStorage.getSeedColor();
    final savedBrightness = await themeStorage.getBrightness();

    emit(
      ThemeState(
        config: AppThemeConfig(
          seedColor: savedColor ?? const Color(0xFF16A34A),
          brightness: savedBrightness ?? Brightness.light,
        ),
      ),
    );
  }

  Future<void> updateSeedColor(Color color) async {
    final updatedConfig = state.config.copyWith(seedColor: color);

    await themeStorage.saveTheme(
      seedColor: updatedConfig.seedColor,
      brightness: updatedConfig.brightness,
    );

    emit(state.copyWith(config: updatedConfig));
  }

  Future<void> updateBrightness(Brightness brightness) async {
    final updatedConfig = state.config.copyWith(brightness: brightness);

    await themeStorage.saveTheme(
      seedColor: updatedConfig.seedColor,
      brightness: updatedConfig.brightness,
    );

    emit(state.copyWith(config: updatedConfig));
  }

  Future<void> applyThemeFromHex(String hexColor) async {
    final color = _hexToColor(hexColor);
    await updateSeedColor(color);
  }

  Color _hexToColor(String hex) {
    String cleaned = hex.replaceAll('#', '').trim();

    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }

    return Color(int.parse(cleaned, radix: 16));
  }
}

