import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/network/connectivity_monitor.dart';
import 'core/theme/locale_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';

/// Returns true for transient connectivity failures that are expected when the
/// device hands off between Wi-Fi and mobile data. These must never crash the
/// app: in-flight requests/sockets are torn down by the OS and surface as
/// uncaught socket/http errors slightly after the network change.
bool _isTransientNetworkError(Object error) {
  return error is SocketException ||
      error is HttpException ||
      error is HandshakeException ||
      error is TlsException;
}

Future<void> main() async {
  // runZonedGuarded + the framework error hooks ensure that an uncaught async
  // error (most commonly a dropped connection while switching from Wi-Fi to
  // mobile data) is logged instead of terminating the app.
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Flutter framework (build/layout/widget) errors.
      FlutterError.onError = (FlutterErrorDetails details) {
        if (_isTransientNetworkError(details.exception)) {
          debugPrint('Ignored transient network error: ${details.exception}');
          return;
        }

        FlutterError.presentError(details);
      };

      // Uncaught errors that reach the platform dispatcher (async gaps,
      // image loading, plugin callbacks, etc.).
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        if (_isTransientNetworkError(error)) {
          debugPrint('Ignored transient network error: $error');
        } else {
          debugPrint('Uncaught platform error: $error');
        }

        // Returning true marks the error as handled so it does not crash.
        return true;
      };

      await di.init();

      // Start watching for Wi-Fi <-> mobile-data switches so stale connections
      // are dropped immediately instead of hanging the next request.
      sl<ConnectivityMonitor>().start();

      await sl<ThemeCubit>().loadSavedTheme();
      await sl<LocaleCubit>().loadSavedLocale();

      debugPrint('APP_NAME: ${AppConfig.appName}');
      debugPrint('API_BASE_URL (Build4All): ${AppConfig.apiBaseUrl}');
      debugPrint(
        'PROJECT_API_BASE_URL (Wholesale): ${AppConfig.projectApiBaseUrl}',
      );
      debugPrint('APP_TYPE: ${AppConfig.appType}');
      debugPrint('OWNER_PROJECT_LINK_ID: ${AppConfig.ownerProjectLinkId}');
      debugPrint('PROJECT_ID: ${AppConfig.projectId}');
      debugPrint('CURRENCY_ID: ${AppConfig.currencyId}');
      debugPrint('DEFAULT_LANGUAGE: ${AppConfig.defaultLanguage}');

      runApp(const App());
    },
    (Object error, StackTrace stack) {
      if (_isTransientNetworkError(error)) {
        debugPrint('Ignored transient network error: $error');
        return;
      }

      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}
