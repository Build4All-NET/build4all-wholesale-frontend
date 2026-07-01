import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/services/auth_service.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';

/// Background message handler. Must be a top-level / static function so the
/// background isolate can find it. The system tray renders the notification
/// automatically, so there is nothing to do here besides initialize Firebase.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // No Firebase config on this build — ignore.
  }
}

/// Registers the device's FCM token with the wholesale backend and manages the
/// Firebase Messaging lifecycle.
///
/// Push is best-effort: if the build has no Firebase config (e.g. a test build),
/// every call degrades to a no-op instead of crashing the app. The heavy
/// notification delivery + storage lives in the backend + shared notify library;
/// this class only registers/unregisters the token and wires the handlers.
class PushNotificationService {
  final ApiClient projectApiClient;
  final AuthService authService;

  PushNotificationService({
    required this.projectApiClient,
    required this.authService,
  });

  bool _initialized = false;
  bool _available = false;
  String? _registeredToken;

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await FirebaseMessaging.instance.requestPermission();
      // Keep the backend in sync when FCM rotates the token.
      FirebaseMessaging.instance.onTokenRefresh.listen(_sendToken);
      _available = true;
    } catch (e) {
      _available = false;
      debugPrint('Push disabled (Firebase not available): $e');
    }
  }

  /// Call after login / on authenticated cold start.
  Future<void> registerForCurrentUser() async {
    await _init();
    if (!_available) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _sendToken(token);
      }
    } catch (e) {
      debugPrint('Push token registration failed: $e');
    }
  }

  /// Call on explicit logout, before the session token is cleared.
  Future<void> unregister() async {
    if (!_available) return;
    try {
      final token = _registeredToken ??
          await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await projectApiClient.dio.delete(
          ApiConfig.notifyDeviceTokens,
          queryParameters: {'fcmToken': token},
        );
      }
      _registeredToken = null;
    } catch (e) {
      debugPrint('Push token unregister failed: $e');
    }
  }

  Future<void> _sendToken(String token) async {
    try {
      final projectId = int.tryParse(AppConfig.ownerProjectLinkId);
      if (projectId == null) return;

      final me = await authService.getWholesaleMe();
      if (me.userId == 0) return;

      final actorType = me.isSupplier ? 'OWNER' : 'CUSTOMER';

      await projectApiClient.dio.post(
        ApiConfig.notifyDeviceTokens,
        data: {
          'projectId': projectId,
          'actorType': actorType,
          'actorId': me.userId,
          'appScope': 'FRONT',
          'fcmToken': token,
          'platform': Platform.isIOS ? 'IOS' : 'ANDROID',
        },
      );
      _registeredToken = token;
    } catch (e) {
      debugPrint('Push token upsert failed: $e');
    }
  }
}
