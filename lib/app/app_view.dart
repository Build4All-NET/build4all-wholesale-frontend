import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/branding/branding_cubit.dart';
import '../core/branding/branding_state.dart';
import '../core/currency/presentation/app_currency_cubit.dart';
import '../core/storage/branding_storage.dart';
import '../core/theme/app_theme_builder.dart';
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
                          onTap: () {
                            final currentFocus = FocusManager.instance.primaryFocus;
                            if (currentFocus != null &&
                                !currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: child,
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
