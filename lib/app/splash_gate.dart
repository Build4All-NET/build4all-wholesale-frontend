import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/auth_storage.dart';
import '../features/auth/data/services/auth_service.dart';
import '../injection_container.dart';

/// First screen shown on every cold start. It restores a previously saved
/// session instead of always dropping the user back on the login screen:
///
/// * no stored token            -> /login
/// * stored token, session ok   -> the right dashboard for the saved role
/// * stored token, refresh dead -> /login (the refresh interceptor clears the
///   session, so the token is gone when we re-check)
///
/// Validating the session here also transparently rotates an expired access
/// token through the refresh interceptor, so a returning user stays logged in.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideStart());
  }

  Future<void> _decideStart() async {
    final authStorage = sl<AuthStorage>();

    final token = await authStorage.getToken();
    if (!mounted) return;

    if (token == null || token.trim().isEmpty) {
      context.go('/login');
      return;
    }

    final role = (await authStorage.getRole())?.toUpperCase().trim() ?? '';
    var profileCompleted = await authStorage.getProfileCompleted() ?? false;

    // Validate the saved session. If the access token expired, the refresh
    // interceptor rotates it here; if the refresh token is also dead it clears
    // the session, so we re-check storage before deciding where to go.
    try {
      final me = await sl<AuthService>().getWholesaleMe();
      profileCompleted = me.profileCompleted;
    } catch (_) {
      final stillLoggedIn = await authStorage.getToken();
      if (stillLoggedIn == null || stillLoggedIn.trim().isEmpty) {
        if (!mounted) return;
        context.go('/login');
        return;
      }
      // Transient (e.g. offline) failure but the session is still valid: trust
      // the stored profile flag and let the destination screen retry its load.
    }

    if (!mounted) return;

    if (role == 'SUPPLIER') {
      context.go(
        profileCompleted ? '/supplier-dashboard' : '/complete-supplier-profile',
      );
    } else if (role == 'RETAILER') {
      context.go(
        profileCompleted ? '/retailer-dashboard' : '/complete-retailer-profile',
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
