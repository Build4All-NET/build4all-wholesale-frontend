import 'package:equatable/equatable.dart';
import 'app_theme_config.dart';

class ThemeState extends Equatable {
  final AppThemeConfig config;

  const ThemeState({
    required this.config,
  });

  ThemeState copyWith({
    AppThemeConfig? config,
  }) {
    return ThemeState(
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [
        config.seedColor.toARGB32(),
        config.brightness,
      ];
}

