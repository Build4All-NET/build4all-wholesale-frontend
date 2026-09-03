import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/branding/branding_cubit.dart';
import '../core/branding/branding_state.dart';
import '../core/currency/presentation/app_currency_cubit.dart';
import '../core/storage/branding_storage.dart';
import '../core/theme/app_theme_builder.dart';
import '../core/theme/app_theme_tokens.dart';
import '../core/theme/locale_cubit.dart';
import '../core/theme/locale_state.dart';
import '../core/theme/runtime_theme_bootstrapper.dart';
import '../core/theme/runtime_theme_service.dart';
import '../core/theme/theme_cubit.dart';
import '../core/theme/theme_state.dart';
import '../injection_container.dart';
import 'app_router.dart';
import '../l10n/app_localizations.dart';
import '../core/config/app_config.dart';
class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<LocaleCubit>()),
        BlocProvider.value(
          value: sl<AppCurrencyCubit>()..loadConfiguredCurrency(),
        ),
        BlocProvider(
          create: (_) => BrandingCubit(BrandingStorage())..loadInitialBranding(),
        ),
        RepositoryProvider.value(value: sl<RuntimeThemeService>()),
      ],
      child: RuntimeThemeBootstrapper(
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {
                return BlocBuilder<BrandingCubit, BrandingState>(
                  builder: (context, brandingState) {
                    final title = brandingState.appName.trim().isNotEmpty
                        ? brandingState.appName.trim()
                        : AppConfig.appName;

                    return MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      title: title,
                      // Global keyboard dismissal: tapping anywhere outside a
                      // text field (on empty screen area) closes the keyboard,
                      // so it never gets stuck open. Taps on buttons/fields
                      // still work because they win the gesture arena.
                      builder: (context, child) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          child: _WebContentWidth(child: child),
                        );
                      },
                      theme: AppThemeBuilder.buildTheme(themeState.config),
                      routerConfig: AppRouter.router,
                      locale: localeState.locale,
                      supportedLocales: const [
                        Locale('en'),
                        Locale('fr'),
                        Locale('ar'),
                      ],
                      localizationsDelegates: const [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Caps the app's content to a sane desktop container width on very wide
/// browser windows, instead of letting it stretch edge-to-edge.
///
/// Grids are made responsive in place (see [responsiveGridColumns]) so they
/// pick up more columns on a wider window rather than a couple of cards
/// stretching to fill it. This cap exists for everything else — forms, lists,
/// single-column detail screens — which have no such logic and would
/// otherwise stretch into unreadably long rows on a wide monitor. 1200px is a
/// typical desktop web app container width: comfortably wider than a phone,
/// short of full-bleed on a large display.
///
/// Native builds are completely unaffected — this only applies on web.
class _WebContentWidth extends StatelessWidget {
  static const double _maxContentWidth = 1200;

  final Widget? child;

  const _WebContentWidth({required this.child});

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();

    if (!kIsWeb) return content;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth ||
            constraints.maxWidth <= _maxContentWidth) {
          return content;
        }

        return ColoredBox(
          color: AppThemeTokens.background,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: _maxContentWidth,
              height: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : null,
              child: content,
            ),
          ),
        );
      },
    );
  }
}
