import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<LocaleCubit>()),
        RepositoryProvider.value(value: sl<RuntimeThemeService>()),
      ],
      child: RuntimeThemeBootstrapper(
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LocaleCubit, LocaleState>(
              builder: (context, localeState) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'B2B Wholesale App',
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
        ),
      ),
    );
  }
}
