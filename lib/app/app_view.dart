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

/// Caps the app's content to a phone-like column on wide desktop browsers.
///
/// Every screen here is designed mobile-first — rows, grids and card aspect
/// ratios are all tuned for a ~400px-wide phone. Left to fill a real desktop
/// browser window, a two-column grid whose cards were sized for that width
/// stretches to hundreds of pixels wide, and their fixed aspect ratio then
/// makes them absurdly tall (exactly what turns the dashboard's quick-action
/// cards into mostly empty boxes). Centering the whole app in a fixed-width
/// column, the same way a phone frame would, sidesteps every one of those
/// layouts without having to fix each screen's grid individually.
///
/// Native builds are completely unaffected — this only applies on web.
class _WebContentWidth extends StatelessWidget {
  static const double _maxContentWidth = 480;

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
