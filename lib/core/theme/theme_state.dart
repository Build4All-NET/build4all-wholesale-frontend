import 'package:equatable/equatable.dart';

import 'app_theme_config.dart';

class ThemeState extends Equatable {
  final AppThemeConfig config;

  const ThemeState({required this.config});

  ThemeState copyWith({AppThemeConfig? config}) {
    return ThemeState(config: config ?? this.config);
  }

  @override
  List<Object?> get props => [
    config.seedColor.toARGB32(),
    config.brightness,
    config.onPrimary.toARGB32(),
    config.background.toARGB32(),
    config.surface.toARGB32(),
    config.textPrimary.toARGB32(),
    config.textSecondary.toARGB32(),
    config.border.toARGB32(),
    config.inputFill.toARGB32(),
    config.error.toARGB32(),
    config.danger.toARGB32(),
    config.muted.toARGB32(),
    config.success.toARGB32(),
    config.radiusSmall,
    config.radiusMedium,
    config.radiusLarge,
    config.buttonHeight,
    config.buttonTextSize,
    config.buttonFullWidth,
    config.cardPadding,
    config.cardElevation,
    config.cardImageHeight,
    config.cardShowShadow,
    config.cardShowBorder,
    config.menuType,
  ];
}
