import 'package:flutter/material.dart';

/// Loading screen shown on cold start while [SessionManager] validates any
/// stored session. The router's global redirect moves the user to their
/// dashboard or to `/login` as soon as the auth status is resolved.
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
